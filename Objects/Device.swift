//
//  Device.swift
//  Cider
//
//  Created by Gabriel Perez on 6/7/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Foundation

enum ProvisioningState: String {
    case NotStarted = "Not Started"
    case Phase1 = "Phase 1"   // Phase 1 Holder
    case Phase1A = "Phase 1A" // Creating workorder if needed
    case Phase1B = "Phase 1B" // Pulling information
    case Phase2 = "Phase 2"   // Phase 2 Holder
    case Phase2A = "Phase 2A" // Restore
    case Phase2B = "Phase 2B" // Prepare / DEP
    case Phase2C = "Phase 2C" // Applications
    case Phase2D = "Phase 2D" // Quality Check
    case Done = "Done"
    case Remove = "Remove"
}

class Device {
    let ecid: String
    let udid: String?
    let serial: String
    fileprivate var wid: Int?
    fileprivate var type: String?
    fileprivate var wifiMAC: String?
    fileprivate var bluetoothMAC: String?
    fileprivate var ios: String?
    fileprivate var asset: String?
    fileprivate var battery: Int?
    fileprivate var provState: ProvisioningState?
    fileprivate var slot: Int
    fileprivate var info: String?
    
    var isProvisioning: Bool = false
    
    var isRestored: Bool = false
    
    
    init(ecid: String, udid: String?, serial: String, slot: Int) {
        self.ecid = ecid
        self.udid = udid
        //self.serial = serial
        self.serial = "S\(serial)"
        self.slot = slot
        
        FTM_Handle.findWO(for: self.serial, in: ProjectManager.selectedProject!.id) { wid in
            if let wid = wid {
                // Work order found
                self.wid = wid
                
                // Set WO to active
                FTM_Handle.updateStatus(forWID: self.wid! , to: .Active)
                
                // Pull info from FTM
                self.getDeviceInfoFTM()
                self.widSet = true
            }
        }
    }
    
    convenience init(ecid: String, serial: String, slot: Int) {
        self.init(ecid: ecid, udid: nil, serial: serial, slot: slot)
    }
    
    /////////////
    // GETTERS //
    /////////////
    
    func getWID() -> Int? {
        return wid
    }
    
    func getIOS() -> String {
        return ios ?? ""
    }
    
    func getAsset() -> String {
        return asset ?? ""
    }
    
    func getBattery() -> Int {
        if battery != nil {
            return battery!
        }
        return 0
    }
    
    func getProvState() -> ProvisioningState {
        if provState != nil {
            return provState!
        }
        return ProvisioningState.NotStarted
    }
    
    func getSlot() -> Int {
        return slot
    }
    
    func getBootedState() -> String {
        return Configurator.getDeviceProperty(.bootedState, ofECID: ecid)
    }
    
    func getInfo() -> String {
        return info ?? ""
    }
    
    /////////////
    // SETTERS //
    /////////////
    
    private var widSet: Bool = false
    func setWID(_ wid: Int) {
        if !widSet {
            self.wid = wid
        }
    }
    
    func setIOS(as newIOS: String) {
        ios = newIOS
    }
    
    func setAsset(as newAsset: String) {
        asset = newAsset
    }
    
    func setProvState(as newState: ProvisioningState) {
        provState = newState
    }
    
    func setInfo(_ message: String) {
        info = message
    }
    
    ///////////////////
    // Configuration //
    ///////////////////
    
    func pushToFTM() {
        FTM_Handle.post(field: .ECID, value: ecid, forWID: wid!)
        FTM_Handle.post(field: .UDID, value: udid!, forWID: wid!)
        FTM_Handle.post(field: .iOS, value: ios!, forWID: wid!)
        FTM_Handle.post(field: .BatCapacity, value: String(battery!), forWID: wid!)
        FTM_Handle.post(field: .WiFiMAC, value: wifiMAC!, forWID: wid!)
        FTM_Handle.post(field: .BTMAC, value: bluetoothMAC!, forWID: wid!)
        FTM_Handle.post(field: .DeviceType, value: type!, forWID: wid!)
    }

    fileprivate func getDeviceInfoFTM() {
        FTM_Handle.get(field: .iOS, forWID: wid!) { ios in
            self.ios = ios
        }
        FTM_Handle.get(field: .AssetTag, forWID: wid!) { asset in
            self.asset = asset
        }
        FTM_Handle.get(field: .provState, forWID: wid!) { provState in
            self.provState = ProvisioningState.init(rawValue: provState ?? "Not Started")
        }
        FTM_Handle.get(field: .BatCapacity, forWID: wid!) { battery in
            if battery != nil {
                self.battery = Int(battery!)
            }
        }
    }
    
    func getDeviceInfoCFGUTIL() {
        ios = Configurator.getDeviceProperty(.firmwareVersion, ofECID: self.ecid)
        battery = Int(Configurator.getDeviceProperty(.batteryCurrentCapacity, ofECID: self.ecid))
        wifiMAC = Configurator.getDeviceProperty(.wifiAddress, ofECID: self.ecid)
        bluetoothMAC = Configurator.getDeviceProperty(.bluetoothAddress, ofECID: self.ecid)
        type = Configurator.getDeviceProperty(.deviceType, ofECID: self.ecid)
    }
}

extension Device: Equatable {
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.ecid == rhs.ecid
    }
}
