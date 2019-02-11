//
//  Shell.swift
//  Cider
//
//  Created by Gabriel Perez on 6/12/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Foundation

// Provides execution of shell commands through Swift
class Executable {
    fileprivate let process: Process
    fileprivate let pipe: Pipe
    
    var enviroment: [String : String]
    
    var includeErrorInOutput: Bool {
        get {
            return self.includeErrorInOutput
        }
        set {
            if newValue {
                process.standardError = pipe
            } else {
                process.standardError = Pipe()
            }
        }
    }
    
    init(path: String, args: [String], withInput input: Any?) {
        process = Process()
        pipe = Pipe()
        
        process.launchPath = path
        process.arguments = args
        if input != nil {
            process.standardInput = input
        }
        process.standardOutput = pipe
        
        // Set general enviroment variables
        enviroment = ProcessInfo.processInfo.environment
        enviroment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        process.environment = enviroment
    }
    
    convenience init(path: String, args: [String]) {
        self.init(path: path, args: args, withInput: nil)
    }
    
    convenience init(path: String) {
        self.init(path: path, args: [], withInput: nil)
    }
    
    func launch(andWait waitingUntilExit: Bool = false) {
        process.launch()
        
        if waitingUntilExit {
            process.waitUntilExit()
        }
    }
    
    func terminate() {
        process.terminate()
    }
    
    func getOutput() -> String {
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)!
    }
    
    func getPipe() -> Pipe {
        return pipe
    }
    
    func getProcess() -> Process {
        return process
    }
    
    func setEnv(variable: String, to value: String) {
        enviroment[variable] = value
        process.environment = self.enviroment
    }
}
