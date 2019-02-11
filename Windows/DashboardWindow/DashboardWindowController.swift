//
//  DashboardWindowController.swift
//  Cider
//
//  Created by Gabriel Perez on 6/10/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Cocoa

class DashboardWindowController: NSWindowController, NSWindowDelegate {
    let refreshRate: Double = 1 // Interval at which dashboard updates (in seconds)
    let cleanRate: Double = 7200 // Interval in which cleandisk is ran (in seconds)
    
    weak var processWindowController: ProcessWindowController?
    
    @IBOutlet weak var projectNameLabel: NSTextField!
    @IBOutlet weak var projectStatusLabel: NSTextField!
    @IBOutlet weak var actionLabel: NSTextField!
    @IBOutlet weak var restoreBtn: NSButton!
    @IBOutlet weak var actionProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var slot1: NSBox!
    @IBOutlet weak var slot2: NSBox!
    @IBOutlet weak var slot3: NSBox!
    @IBOutlet weak var slot4: NSBox!
    @IBOutlet weak var slot5: NSBox!
    @IBOutlet weak var slot6: NSBox!
    @IBOutlet weak var slot7: NSBox!
    @IBOutlet weak var slot8: NSBox!
    @IBOutlet weak var slot9: NSBox!
    @IBOutlet weak var slot10: NSBox!
    
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name(rawValue: "DashboardWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Check if project was selected and set the project name label
        if let selectedProject = ProjectManager.selectedProject {
            projectNameLabel.stringValue = selectedProject.name
        }
        
        // Initialize all slots
        DashboardManager.slots.append(Slot(1, box: slot1))
        DashboardManager.slots.append(Slot(2, box: slot2))
        DashboardManager.slots.append(Slot(3, box: slot3))
        DashboardManager.slots.append(Slot(4, box: slot4))
        DashboardManager.slots.append(Slot(5, box: slot5))
        DashboardManager.slots.append(Slot(6, box: slot6))
        DashboardManager.slots.append(Slot(7, box: slot7))
        DashboardManager.slots.append(Slot(8, box: slot8))
        DashboardManager.slots.append(Slot(9, box: slot9))
        DashboardManager.slots.append(Slot(10, box: slot10))
        
        // Start the device listener
        DeviceManager.startListener()
        
        // Start the slot updater
        DashboardManager.startUpdater()
        
        // Disk clean timer
        // _ = Timer.scheduledTimer(withTimeInterval: cleanRate, repeats: true, block: {_ in self.processWindowController!.runCleandisk()})
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(self)
    }
    
    func processStarted() {
        projectStatusLabel.stringValue = "Process is running..."
        projectStatusLabel.textColor = NSColor.blue
    }
    
    func processStopped() {
        projectStatusLabel.stringValue = "Process is not running"
        projectStatusLabel.textColor = NSColor.red
    }
    
    func enableSlots() {
        restoreBtn.isEnabled = true
        
        for slot in DashboardManager.slots {
            slot.serialView?.isEnabled = true
            slot.selectorBtn?.isEnabled = true
        }
    }
    
    func disableSlots() {
        restoreBtn.isEnabled = false
        
        for slot in DashboardManager.slots {
            slot.serialView?.isEnabled = false
            slot.selectorBtn?.isEnabled = false
        }
    }
    
    @IBAction func restoreDevicesBtnPressed(_ sender: NSButton) {
        var args: [String] = []
        
        // Check which slots are selected
        for slot in DashboardManager.slots {
            if let device = slot.assignedDevice {
                print(device.serial)
                if let selectorBtn = slot.selectorBtn {
                    print(device.serial)
                    if selectorBtn.state == NSButton.StateValue.on {
                        print(device.serial)
                        args.append(device.ecid)
                    }
                }
            }
        }
        
        // Restore caution alert
        let alert = NSAlert()
        alert.messageText = "Caution"
        alert.informativeText = "Restoring devices will wipe all data.\nContinue with the restore?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Restore")
        alert.addButton(withTitle: "Cancel")
        let response = alert.runModal()
        
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            let script = Configurator.restore(args)
            
            let pipe = Pipe()
            script.standardOutput = pipe
            
            let outHandle = pipe.fileHandleForReading
            
            disableSlots()
    
            actionLabel.stringValue = "Restoring..."
            actionLabel.isHidden = false
            
            actionProgressIndicator.startAnimation(self)
            actionProgressIndicator.isHidden = false
            
            // Oberserver for continuously updating action process
            outHandle.readabilityHandler = { pipe in
                if let str = String(data: pipe.availableData, encoding: .utf8) {
                    print(str)
                    DispatchQueue.main.sync {

                        // Step Index
                        let stepIndex = str.index(str.startIndex, offsetBy: 6)

                        // Progress Index
                        if let i = str.index(of: "]") {
                            if str.count >= str.distance(from: str.startIndex, to: i) + 2 {
                                let start = str.index(i, offsetBy: 2)
                                let end = str.index(str.endIndex, offsetBy: -2)
                                let range = start..<end
                                
                                if let progressValue = Double(str[range]) {
                                    self.actionProgressIndicator.doubleValue = progressValue
                                }
                            }
                        }

                        switch str[stepIndex] {
                        case "1": // Downloading step
                            self.actionLabel.stringValue = "Downloading iOS..."
                        case "2": // Unzipping step
                            self.actionLabel.stringValue = "Unzipping iOS..."
                        case "3": // Installing step
                            self.actionLabel.stringValue = "Installing iOS..."
                        default:
                            break
                        }

                    }
                } else {
                    print("Error decoding data: \(pipe.availableData)")
                }
            }
            
            var terminationObs : NSObjectProtocol!
            terminationObs = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: script, queue: nil) {
                notification -> Void in
                self.actionLabel.isHidden = true
                self.actionLabel.stringValue = "No Action"
                
                self.actionProgressIndicator.stopAnimation(self)
                self.actionProgressIndicator.isHidden = true
                
                self.enableSlots()
                
                NotificationCenter.default.removeObserver(terminationObs)
            }
            
            script.launch()
        }
    }
}
