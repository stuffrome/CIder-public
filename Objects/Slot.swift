//
//  Slot.swift
//  Cider
//
//  Created by Gabriel Perez on 6/15/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Cocoa

fileprivate enum SlotItemIdentifier {
    static let serialView = NSUserInterfaceItemIdentifier(rawValue: "serialView")
    static let serialLabel = NSUserInterfaceItemIdentifier(rawValue: "serialLabel")
    static let iosView = NSUserInterfaceItemIdentifier(rawValue: "iosView")
    static let iosLabel = NSUserInterfaceItemIdentifier(rawValue: "iosLabel")
    static let assetView = NSUserInterfaceItemIdentifier(rawValue: "assetView")
    static let assetLabel = NSUserInterfaceItemIdentifier(rawValue: "assetLabel")
    static let batteryView = NSUserInterfaceItemIdentifier(rawValue: "batteryView")
    static let batteryLabel = NSUserInterfaceItemIdentifier(rawValue: "batteryLabel")
    static let stateView = NSUserInterfaceItemIdentifier(rawValue: "stateView")
    static let stateLabel = NSUserInterfaceItemIdentifier(rawValue: "stateLabel")
    static let infoView = NSUserInterfaceItemIdentifier(rawValue: "infoView")
    static let infoLabel = NSUserInterfaceItemIdentifier(rawValue: "infoLabel")
    static let selector = NSUserInterfaceItemIdentifier(rawValue: "selector")
}

class Slot {
    let slotNumber: Int
    var assignedDevice: Device?
    var box: NSBox
    var view: NSView
    var serialLabel: NSTextField?
    var serialView: NSTextField?
    var iosLabel: NSTextField?
    var iosView: NSTextField?
    var assetLabel: NSTextField?
    var assetView: NSTextField?
    var batteryLabel: NSTextField?
    var batteryView: NSTextField?
    var stateLabel: NSTextField?
    var stateView: NSTextField?
    var infoLabel: NSTextField?
    var infoView: NSTextField?
    var selectorBtn: NSButton?
    
    var isRestoring: Bool = false
    
    
    init(_ slot: Int, box: NSBox) {
        self.slotNumber = slot
        self.box = box
        self.view = self.box.subviews[0]
        setControls()
    }
    
    func assignDevice(_ device: Device) {
        assignedDevice = device
        view.isHidden = false
    }
    
    func setControls() {
        for subview in view.subviews {
            
            if let stack = subview as? NSStackView {
                for substack in stack.subviews {
                    for control in substack.subviews {
                        switch control.identifier {
                        case SlotItemIdentifier.serialView:
                            serialView = control as? NSTextField
                        case SlotItemIdentifier.serialLabel:
                            serialLabel = control as? NSTextField
                        case SlotItemIdentifier.iosView:
                            iosView = control as? NSTextField
                        case SlotItemIdentifier.iosLabel:
                            iosLabel = control as? NSTextField
                        case SlotItemIdentifier.assetView:
                            assetView = control as? NSTextField
                        case SlotItemIdentifier.assetLabel:
                            assetLabel = control as? NSTextField
                        case SlotItemIdentifier.batteryView:
                            batteryView = control as? NSTextField
                        case SlotItemIdentifier.batteryLabel:
                            batteryLabel = control as? NSTextField
                        case SlotItemIdentifier.stateView:
                            stateView = control as? NSTextField
                        case SlotItemIdentifier.stateLabel:
                            stateLabel = control as? NSTextField
                        case SlotItemIdentifier.infoView:
                            infoView = control as? NSTextField
                        case SlotItemIdentifier.infoLabel:
                            infoLabel = control as? NSTextField
                        default:
                            break
                        }
                    }
                }
            }
            
            if subview.identifier == SlotItemIdentifier.selector {
                selectorBtn = subview as? NSButton
            }
            
        }
    }
    
    func loadInfo() {
        if let device = assignedDevice {
            let serialCount = device.serial.count
            
            if serialCount == 13 || serialCount == 12 { // Good Serial
                serialView!.stringValue = device.serial
            }
            
            iosView!.stringValue = device.getIOS()
            assetView!.stringValue = device.getAsset()
            stateView!.stringValue = device.getProvState().rawValue
            batteryView!.stringValue = String(device.getBattery())
            infoView!.stringValue = device.getInfo()
            
            setSlotColor(forState: device.getProvState())
        }
    }
    
    func setSlotColor(forState state: ProvisioningState) {
        switch state {
        case .Phase2C:
            box.fillColor = NSColor.yellow
        case .Phase2D:
            box.fillColor = NSColor.blue
        case .Done:
            box.fillColor = NSColor.green
        default:
            box.fillColor = NSColor.lightGray
        }
    }
    
    func clear() {
        if !isRestoring {
            // Remove info
            assignedDevice = nil
            //serialView!.stringValue = ""
        
            // Disable interface
            view.isHidden = true
        }
    }
}
