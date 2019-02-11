//
//  ConfiguratorFramework.swift
//  Cider
//
//  Created by Gabriel Perez on 6/6/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//
// This framework provides ease of use of cfgutil in Swift
//

import Foundation

enum DeviceProperty: String {
    case activationState = "activationState"
    case batteryCurrentCapacity = "batteryCurrentCapacity"
    case bluetoothAddress = "bluetoothAddress"
    case bootedState = "bootedState"
    case buildVersion = "buildVersion"
    case configurationProfiles = "configurationProfiles"
    case deviceClass = "deviceClass"
    case deviceType = "deviceType"
    case ECID = "ECID"
    case ethernetAddress = "ethernetAddress"
    case firmwareVersion = "firmwareVersion"
    case installedApps = " installedApps"
    case isPaired = "isPaired"
    case isRestorable = "isRestorable"
    case isSupervised = "isSupervised"
    case locationID = "locationID"
    case name = "name"
    case organizationName = "organizationName"
    case pairingAllowed = "pairingAllowed"
    case provisioningProfiles = "provisioningProfiles"
    case serialNumber = "serialNumber"
    case UDID = "UDID"
    case wifiAddress = "wifiAddress"
}

enum Configurator {
    
    static func cfgutil(_ args: [String]) -> Executable {
        let command = Executable(path: "/usr/local/bin/cfgutil", args: args)
        command.launch()
        
        return command
    }
    
    static func cfgutilTest(_ args: [String]) -> Process {
        
        var arguments = ["-lc", "cfgutil"]
        
        for arg in args {
            arguments[1].append(" \(arg)")
        }
        
        let process = Process()
        
        process.launchPath = "/bin/bash"
        process.arguments = arguments
        
        var enviroment = ProcessInfo.processInfo.environment
        enviroment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        process.environment = enviroment
        
        return process
    }
    
    // Restores all devices or the device with the provided ECID
    static func restore(_ ecids: [String]) -> Process {
        var arguments: [String] = []
        for ecid in ecids {
            arguments.append("-e")
            arguments.append(ecid)
        }
        arguments.append("restore")
        //arguments.append("-I")
        //arguments.append("/Users/gabriel.perez/Downloads/iPad_64bit_TouchID_ASTC_11.4.1_15G77_Restore.ipsw")
        
        return cfgutilTest(arguments)
    }
    
    static func getDeviceProperty(_ property: DeviceProperty, ofECID ecid: String) -> String {
        let valueRaw = cfgutil(["-e", ecid, "get", property.rawValue]).getOutput()
        let valueFixed = valueRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return valueFixed
    }
    
}
