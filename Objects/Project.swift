//
//  Project.swift
//  Cider
//
//  Created by Gabriel Perez on 6/12/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Foundation

struct Project {
    // Identifying properties
    let name: String
    let id: String
    
    // Process properties
    fileprivate var restoring: Bool
    fileprivate var preparing: Bool
    fileprivate var enrolling: Bool
    fileprivate var depUsername: String?
    fileprivate var depPassword: String?
    fileprivate var installApps: Bool
    fileprivate var appChecksum: String?
    fileprivate var selfShutdown: Bool
    
    // Additional items
    // supervision key and cert
    
    
    init(name: String,
         id: String,
         restoring: Bool,
         preparing: Bool,
         enrolling: Bool,
         depUsername: String?,
         depPassword: String?,
         installApps: Bool,
         appChecksum: String?,
         selfShutdown: Bool) {
        
        self.name = name
        self.id = id
        self.restoring = restoring
        self.preparing = preparing
        self.enrolling = enrolling
        self.depUsername = depUsername
        self.depPassword = depPassword
        self.installApps = installApps
        self.appChecksum = appChecksum
        self.selfShutdown = selfShutdown
    }
    
    /////////////
    // GETTERS //
    /////////////
    
    func isRestoring() -> Bool {
        return restoring
    }
    
    func isPreparing() -> Bool {
        return preparing
    }
    
    func isEnrolling() -> Bool {
        return enrolling
    }
    
    func isInstallingApps() -> Bool {
        return installApps
    }
    
}
