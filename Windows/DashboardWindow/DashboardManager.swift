//
//  DashboardModel.swift
//  Cider
//
//  Created by Gabriel Perez on 6/14/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Foundation

class DashboardManager {
    static var slots: [Slot] = [] // Slot objects array
    
    private static let refreshRate: Double = 0.5 // Interval at which dashboard updates (in seconds)
    private static let cleanRate: Double = 7200 // Interval in which cleandisk is ran (in seconds)
    
    private static var slotsUpdater: Timer?
    
    static func startUpdater() {
        slotsUpdater = Timer.scheduledTimer(withTimeInterval: refreshRate, repeats: true, block: {_ in updateSlots()})
    }
    
    private static func updateSlots() {
        for slot in slots {
            var slotHasDevice = false
            
            for device in DeviceManager.connectedDevices {
                if slot.slotNumber == device.getSlot() {
                    slot.assignDevice(device)
                    slotHasDevice = true
                }
            }
            
            if !slotHasDevice {
                slot.clear()
            }
            
            slot.loadInfo()
        }
    }
    
}
