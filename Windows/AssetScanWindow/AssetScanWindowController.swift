//
//  AssetScanWindowController.swift
//  Cider
//
//  Created by Gabriel Perez on 7/11/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Cocoa

class AssetScanWindowController: NSWindowController {
    
    @IBOutlet weak var serial1: NSTextField!
    @IBOutlet weak var serial2: NSTextField!
    @IBOutlet weak var serial3: NSTextField!
    @IBOutlet weak var serial4: NSTextField!
    @IBOutlet weak var serial5: NSTextField!
    @IBOutlet weak var serial6: NSTextField!
    @IBOutlet weak var serial7: NSTextField!
    @IBOutlet weak var serial8: NSTextField!
    @IBOutlet weak var serial9: NSTextField!
    @IBOutlet weak var serial10: NSTextField!
    
    @IBOutlet weak var asset1: NSTextField!
    @IBOutlet weak var asset2: NSTextField!
    @IBOutlet weak var asset3: NSTextField!
    @IBOutlet weak var asset4: NSTextField!
    @IBOutlet weak var asset5: NSTextField!
    @IBOutlet weak var asset6: NSTextField!
    @IBOutlet weak var asset7: NSTextField!
    @IBOutlet weak var asset8: NSTextField!
    @IBOutlet weak var asset9: NSTextField!
    @IBOutlet weak var asset10: NSTextField!
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name(rawValue: "AssetScanWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        for device in DeviceManager.connectedDevices {
            switch device.getSlot() {
            case 1:
                serial1.stringValue = device.serial
                asset1.stringValue = device.getAsset()
            case 2:
                serial2.stringValue = device.serial
                asset2.stringValue = device.getAsset()
            case 3:
                serial3.stringValue = device.serial
                asset3.stringValue = device.getAsset()
            case 4:
                serial4.stringValue = device.serial
                asset4.stringValue = device.getAsset()
            case 5:
                serial5.stringValue = device.serial
                asset5.stringValue = device.getAsset()
            case 6:
                serial6.stringValue = device.serial
                asset6.stringValue = device.getAsset()
            case 7:
                serial7.stringValue = device.serial
                asset7.stringValue = device.getAsset()
            case 8:
                serial8.stringValue = device.serial
                asset8.stringValue = device.getAsset()
            case 9:
                serial9.stringValue = device.serial
                asset9.stringValue = device.getAsset()
            case 10:
                serial10.stringValue = device.serial
                asset10.stringValue = device.getAsset()
            default:
                break
            }
        }
    }
    
    @IBAction func assetEntered(_ sender: NSTextField) {
        for device in DeviceManager.connectedDevices {
            if device.getSlot() == sender.tag {
                device.setAsset(as: sender.stringValue)
            }
        }
        
        switch sender.tag {
        case 1:
            if !serial2.stringValue.isEmpty {
                asset2.setAccessibilityFocused(true)
                break
            }
            fallthrough
        case 2:
            if !serial3.stringValue.isEmpty {
                asset3.setAccessibilityFocused(true)
                break
            }
            fallthrough
        case 3:
            if !serial4.stringValue.isEmpty {
                asset4.setAccessibilityFocused(true)
                break
            }
            fallthrough
        case 4:
            if !serial5.stringValue.isEmpty {
                asset5.setAccessibilityFocused(true)
                break
            }
            fallthrough
        case 5:
            if !serial6.stringValue.isEmpty {
                asset6.setAccessibilityFocused(true)
                break
            }
            fallthrough
        case 6:
            if !serial7.stringValue.isEmpty {
                asset7.setAccessibilityFocused(true)
                break
            }
            fallthrough
        case 7:
            if !serial8.stringValue.isEmpty {
                asset8.setAccessibilityFocused(true)
                break
            }
            fallthrough
        case 8:
            if !serial9.stringValue.isEmpty {
                asset9.setAccessibilityFocused(true)
                break
            }
            fallthrough
        case 9:
            if !serial10.stringValue.isEmpty {
                asset10.setAccessibilityFocused(true)
                break
            }
            fallthrough
        case 10:
            asset10.resignFirstResponder()
        default:
            break
        }
    }
}
