//
//  ProcessModel.swift
//  Cider
//
//  Created by Gabriel Perez on 6/15/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Foundation

enum MessageType: String {
    case INFO =    "INFO    | "
    case CAUTION = "CAUTION | "
    case WARNING = "WARNING | "
}

fileprivate class RestoreThread: Thread {
    override func main() {
        
    }
}

protocol ProvisionerDelegate: class {
    func postMessage(_ string: String, as type: MessageType)
}

// Provisioner will control the provisioning process
class Provisioner {
    
    // Provisioner delegate for sending message updates to the controller
    weak var delegate: ProvisionerDelegate!
    
    private var processIsRunning = false
    
    // ECID for the next restore cycle
    private var ecidsToRestore: [String] = []
    
    
    // RESTORE CYCLE INFO
    
    var restoringDevices: Bool = false
    
    // Timers
    private var restoreTimer = Timer()
    private var phaseUpdaterTimer = Timer()
    
    // Timer rates
    private var restoreTimerRate: Double =  20 // seconds
    private var phaseUpdaterTimerRate: Double = 0.2 // seconds
    
    func startProvisioning() {
        
        phaseUpdaterTimer = Timer.scheduledTimer(withTimeInterval: phaseUpdaterTimerRate, repeats: true, block: {_ in self.updatePhases()})
        
    }
    
    func stopProvisioning() {
        
        phaseUpdaterTimer.invalidate()
        
    }
    
    func updatePhases() {
        
        DispatchQueue.global().async {
            
            for device in DeviceManager.connectedDevices {
                
                if device.isProvisioning {
                    // Just wait
                } else {
                    
                    device.isProvisioning = true
                    
                    // Will continue each device from it's last step in the process
                    process: switch device.getProvState() {
                    case .NotStarted:
                        fallthrough
                        
                    case .Phase1:
                        device.setProvState(as: .Phase1)
                        
                        ///////////////////////////////////////////////////////////////////////////////////////////////
                        //                                                                                           //
                        //  PHASE 1: Will check if the device was able to retrieve a WO and pull information from    //
                        //  it. Otherwise it will create a work order for the device and push the information        //
                        //  retrieved from cfgutil to FTM.                                                           //
                        //                                                                                           //
                        ///////////////////////////////////////////////////////////////////////////////////////////////
                        
                        fallthrough
                        
                    case .Phase1A:
                        device.setProvState(as: .Phase1A)
                        
                        if device.getWID() == nil {
                            
                            device.setInfo("Creating WO...")
                            DispatchQueue.main.sync {
                                self.delegate.postMessage("Creating a WO for \(device.serial)", as: .CAUTION)
                            }
                            
                            // Create a WO for the device
                            //device.setWID(FTM_Handle.createWO(forSerial: device.serial, inPID: ProjectManager.selectedProject!.id))
                            
                            // Set WO to active
                            //FTM_Handle.updateStatus(forWID: device.getWID()! , to: .Active)
                        }
                        
                        fallthrough
                        
                    case .Phase1B:
                        device.setProvState(as: .Phase1B)
                        
                        // Pull info from device using cfgutil
                        device.setInfo("Pulling information...")
                        device.getDeviceInfoCFGUTIL()
                        
                        // Push info onto FTM
                        device.setInfo("Sending to FTM...")
                        device.pushToFTM()
                        
                        fallthrough
                        
                    case .Phase2:
                        device.setProvState(as: .Phase2)
                        
                        ///////////////////////////////////////////////////////////////////////////////////////////////
                        //                                                                                           //
                        //  PHASE 2: Will restore, prepare, enroll and install applications for devices as assigned  //
                        //  to the running project. Each portion is designated by the project and can be changed by  //
                        //  enabling/diabling in the project database.                                               //
                        //                                                                                           //
                        ///////////////////////////////////////////////////////////////////////////////////////////////
                        
                        fallthrough
                        
                    case .Phase2A:
                        
                        // Check if project has been set to restore devices
                        if ProjectManager.selectedProject!.isRestoring() {
                            device.setProvState(as: .Phase2A)
                            
                            DispatchQueue.main.sync {
                                self.delegate.postMessage("\(device.serial) set to restore.", as: .CAUTION)
                            }
                            
                            // Add device to the next restore cycle
                            device.setInfo("Will restore...")
                            self.ecidsToRestore.append(device.ecid)
                            
                            //if !self.restoringDevices {
                                DispatchQueue.main.async {
                                    // Reset restore timer
                                    self.restoreTimer.invalidate()
                                    self.restoreTimer = Timer.scheduledTimer(withTimeInterval: self.restoreTimerRate, repeats: false, block: {_ in self.restoreDevicesInQueue()})
                                }
                            //}
                            
                            break process
                        }
                        
                        fallthrough
                        
                    case .Phase2B:
                        
                        // Check if project has been set to prepare and enroll device
                        if ProjectManager.selectedProject!.isPreparing() {
                            device.setProvState(as: .Phase2B)
                            
                            device.setInfo("Installing profile...")
                            // Install wifi profile
                            
                            if ProjectManager.selectedProject!.isEnrolling() {
                                
                                device.setInfo("Preparing & Enrolling")
                                // Prepare with enrollment
                                
                            } else {
                                
                                device.setInfo("Preparing")
                                // Prepare without enrollment
                                
                            }
                            
                        }
                        
                        fallthrough
                        
                    case .Phase2C:
                        
                        if ProjectManager.selectedProject!.isInstallingApps() {
                            device.setProvState(as: .Phase2C)
                            
                            device.setInfo("Installing apps...")
                            // Wait for apps to install
                        }
                        
                        fallthrough
                        
                    case .Phase2D:
                        
                        // Quality Check
                        device.setProvState(as: .Phase2D)
                        
                        device.setInfo("Call QC Technician")
                        
                        fallthrough
                        
                    case .Done:
                        break
                    case .Remove:
                        break
                    }
                }
            }
        }
        
    }
    
    func restoreDevicesInQueue() {
        restoringDevices = true
        
        let ecidsBeingRestored = self.ecidsToRestore
        self.ecidsToRestore = []
        
        var message = "Restoring"
        
        for device in DeviceManager.connectedDevices {
            for ecid in ecidsBeingRestored {
                if device.ecid == ecid {
                    device.setInfo("Restoring...")
                    message.append(" \(device.serial),")
                }
            }
        }
        
        message.removeLast()
        
        self.delegate.postMessage(message, as: .INFO)
        
        DispatchQueue.global(qos: .background).async {
        
            let script = Configurator.restore(ecidsBeingRestored)
            
            let pipe = Pipe()
            script.standardOutput = pipe
        
            let outHandle = pipe.fileHandleForReading
        
            outHandle.readabilityHandler = { pipe in
                if let line = String(data: pipe.availableData, encoding: .utf8) {
                    print(line)
                } else {
                    print("Error decoding data: \(pipe.availableData)")
                }
            }
        
            var terminationObs : NSObjectProtocol!
            terminationObs = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: script, queue: nil) {
                notification -> Void in
                
                message = "Restoring complete on"
                
                for device in DeviceManager.connectedDevices {
                    for ecid in ecidsBeingRestored {
                        if device.ecid == ecid {
                            device.setInfo("Restored")
                            message.append(" \(device.serial),")
                            
                            device.setProvState(as: .Phase2B)
                            device.isProvisioning = false
                        }
                    }
                }
                
                message.removeLast()
                
                
                DispatchQueue.main.sync {
                    self.delegate.postMessage(message, as: .INFO)
                }
                
                self.restoringDevices = false
                
                NotificationCenter.default.removeObserver(terminationObs)
            }
            
            script.launch()
            
            script.waitUntilExit()
        
        }
    }
}
