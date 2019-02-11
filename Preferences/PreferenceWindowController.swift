//
//  PreferenceWindowController.swift
//  Cider
//
//  Created by Gabriel Perez on 6/19/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Cocoa

class PreferenceWindowController: NSWindowController {
    
    @IBOutlet weak var stationIDTextField: NSTextField!
    @IBOutlet weak var scriptsDirectoryTextField: NSTextField!
    @IBOutlet weak var pp15RadioBtn: NSButton!
    @IBOutlet weak var thunderRadioBtn: NSButton!
    
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name(rawValue: "PreferenceWindowController")
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        stationIDTextField.stringValue = defaults.string(forKey: "StationID") ?? ""
        scriptsDirectoryTextField.stringValue = defaults.string(forKey: "ScriptsDirectory") ?? ""
        
        let hubType = defaults.value(forKey: "HubType") as? String
        
        if let type = hubType {
            switch type {
            case HubType.pp15:
                pp15RadioBtn.state = NSButton.StateValue.on
            case HubType.thundersync:
                thunderRadioBtn.state = NSButton.StateValue.on
            default:
                break
            }
        }
    }
    
    @IBAction func hubTypeChange(_ sender: NSButton) {
        let selection = sender.title
        
        switch selection {
        case "PP 15":
            defaults.set(HubType.pp15, forKey: "HubType")
            print("Set to PP15")
        case "ThunderSync 16":
            defaults.set(HubType.thundersync, forKey: "HubType")
            print("Set to ThunderSync")
        default:
            break
        }
    }
    
    @IBAction func stationValueChange(_ sender: NSTextField) {
        if let stationNumber = Int(sender.stringValue) {
            if stationNumber >= 1 && stationNumber <= 20 {
                defaults.set(stationNumber, forKey: "StationID")
            }
        }
    }
    @IBAction func scriptsDirectoryChanged(_ sender: NSTextField) {
        defaults.set(sender.stringValue, forKey: "ScriptsDirectory")
    }
}
