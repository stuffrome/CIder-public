//
//  PreferenceModel.swift
//  Cider
//
//  Created by Gabriel Perez on 6/19/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Foundation

enum HubType {
    static let pp15 = "PP 15"
    static let thundersync = "ThunderSync 16"
}

let defaults = UserDefaults.standard

// Default settings

func setDefaultSettings() {
    if defaults.string(forKey: "ScriptsDirectory") == nil {
        defaults.set("/Users/qc/AppleProvisioning/", forKey: "ScriptsDirectory")
    }
    
    if defaults.string(forKey: "HubType") == nil {
        defaults.set(HubType.pp15, forKey: "HubType")
    }
}
