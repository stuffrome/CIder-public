//
//  DeviceManager.swift
//  Cider
//
//  Created by Gabriel Perez on 7/1/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Foundation

fileprivate class DeviceListener: Thread {
    override func main() {
        while DeviceManager.listeningForDevices {
            DeviceManager.listenForDevices()
        }
    }
}

class DeviceManager {
    static var connectedDevices: [Device] = []
    
    static fileprivate var listeningForDevices: Bool = false
    
    static private let deviceListener = DeviceListener()
    
    static fileprivate func listenForDevices() {
        let data = getData()
        let maxDevices = 10
        
        // Check for plugged devices
        if connectedDevices.count <= maxDevices {
            for deviceInfo in data {
                var deviceAlreadyConnected = false
                
                for device in connectedDevices {
                    if deviceInfo["ECID"] == device.ecid {
                        deviceAlreadyConnected = true
                    }
                }
                
                if !deviceAlreadyConnected {
                    createDevice(from: deviceInfo)
                }
            }
        }
        
        // Check for finished devices
        for device in connectedDevices {
            var deviceConnected = true
            
            if device.getProvState() == .Remove {
                deviceConnected = false
            }
            
            if !deviceConnected {
                if let index = connectedDevices.index(of: device) {
                    connectedDevices.remove(at: index)
                }
            }
        }
    }
    
    static private func getData() -> [[String:String]] {
        var data: [[String:String]] = []
        
        let script = Configurator.cfgutil(["list"])
        var devicesRaw = script.getOutput().components(separatedBy: "\n")
        
        // Remove any leading or trailing newlines
        for rawInfo in devicesRaw {
            if rawInfo == "" {
                devicesRaw.remove(at: devicesRaw.index(of: rawInfo)!)
            }
        }
        
        // Sort out devices
        if !devicesRaw.isEmpty {
            for rawInfo in devicesRaw {
                var deviceInfo: [String:String] = [:]
                
                var seperatedDeviceInfo = rawInfo.components(separatedBy: .whitespaces)
                
                deviceInfo["ECID"] = seperatedDeviceInfo[3]
                deviceInfo["UDID"] = seperatedDeviceInfo[5]
                deviceInfo["Location"] = seperatedDeviceInfo[7]
                
                data.append(deviceInfo)
            }
        }
        
        return data
    }
    
    static private func createDevice(from deviceInfo: [String:String]) {
        let ecid = deviceInfo["ECID"]!
        let udid = deviceInfo["UDID"]!
        let location = deviceInfo["Location"]!
        let serial = Configurator.getDeviceProperty(.serialNumber, ofECID: ecid)
        var slot: Int = 0
        
        switch defaults.string(forKey: "HubType")! {
        case HubType.pp15: // Will use memory location
            slot = getSlot(forIdentifier: location)
        case HubType.thundersync: // Will use UDID
            slot = getSlot(forIdentifier: udid)
        default:
            break
        }
        
        
        let newDevice = Device(ecid: ecid, udid: udid, serial: serial, slot: slot)
        DeviceManager.connectedDevices.append(newDevice)
    }
    
    static private func getSlot(forIdentifier identifier: String) -> Int {
        
        switch defaults.string(forKey: "HubType")! {
        case HubType.pp15: // Will use memory location
            
            let slots = ["14" : 1,
                         "13" : 2,
                         "12" : 3,
                         "11" : 4,
                         "44" : 5,
                         "43" : 6,
                         "42" : 7,
                         "21" : 8,
                         "22" : 9,
                         "23" : 10 ]
            
            let start = identifier.index(identifier.startIndex, offsetBy: 6)
            let end = identifier.index(identifier.endIndex, offsetBy: -2)
            let range = start..<end
            
            let location = String(identifier[range])
            
            if let slot = slots[location] {
                return slot
            }
            
            
        case HubType.thundersync: // Will use UDID
            
            if let filePath = Bundle.main.path(forResource: "thundersyncDeviceUDID", ofType: "py") {
                let script = Executable(path: "/usr/bin/python", args: [filePath])
                script.launch()
                
                let connectedSlots = script.getOutput().components(separatedBy: "\n")
                
                for slot in connectedSlots {
                    let info = slot.components(separatedBy: ":")
                    
                    if info.count < 2 || info[0] == "" {
                        break
                    }
                    
                    if identifier == info[1] {
                            if let slotNumber = Int(info[0]) {
                            return slotNumber
                        }
                    }
                }
            }
            
        default:
            break
        }
        
        return 0
    }
    
    static func startListener() {
        listeningForDevices = true
        deviceListener.start()
    }
}
