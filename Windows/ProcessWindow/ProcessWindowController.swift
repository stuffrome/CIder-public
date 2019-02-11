//
//  ProcessWindowController.swift
//  Cider
//
//  Created by Gabriel Perez on 6/12/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Cocoa

class ProcessWindowController: NSWindowController, NSWindowDelegate {
    
    weak var dashboardWindowController: DashboardWindowController?
    
    private let provisioner = Provisioner()
    
    @IBOutlet var debugTextView: NSTextView!
    @IBOutlet weak var restartBtn: NSButton!
    @IBOutlet weak var stopBtn: NSButton!
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name(rawValue: "ProcessWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        restartBtn.isEnabled = false
        stopBtn.isEnabled = true
        
        provisioner.delegate = self
        
        startProcess()
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        self.window?.orderOut(self)
        return false
    }
    
    func windowWillClose(_ notification: Notification) {
        // Check that a process has started then terminate it
    }
    
    // Starts the process for the project
    func startProcess() {
        provisioner.startProvisioning()
    }
    
    func stopProcess() {
        provisioner.stopProvisioning()
    }
    
    func runCleandisk() {
        if let path = Bundle.main.path(forResource: "cleandisk", ofType: "sh") {
            let script = Executable(path: "/bin/sh", args: [path])
            script.launch()
            self.debugTextView.string.append(script.getOutput())
        }
    }
    
    @IBAction func cleandiskBtnPressed(_ sender: NSButton) {
        runCleandisk()
    }
    
    @IBAction func stopBtnPressed(_ sender: NSButton) {
        // Check that a process has started then terminate it
        
        dashboardWindowController!.processStopped()
        
        restartBtn.isEnabled = true
        stopBtn.isEnabled = false
    }
    
    @IBAction func restartBtnPressed(_ sender: NSButton) {
        // Clear textbox for restarted process
        self.debugTextView.string = ""
        
        // Clean disk before starting a new process
        //runCleandisk()
        
        // Restart process
        startProcess()
        
        
        dashboardWindowController!.processStarted()
        
        restartBtn.isEnabled = false
        stopBtn.isEnabled = true
    }
}

extension ProcessWindowController: ProvisionerDelegate {
    func postMessage(_ string: String, as type: MessageType) {
        self.debugTextView.string.append("\(string)\n")
    }
}
