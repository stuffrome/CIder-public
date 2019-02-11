//
//  AppDelegate.swift
//  Cider
//
//  Created by Gabriel Perez on 6/6/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var projectSelectionWindowController: ProjectSelectionWindowController?
    var dashboardWindowController: DashboardWindowController?
    var assetScanWindowController: AssetScanWindowController?
    var processWindowController: ProcessWindowController?
    var preferenceWindowController: PreferenceWindowController?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set the default settings for any missing user settings
        setDefaultSettings()
        
        // Load the project selection window
        let window = ProjectSelectionWindowController()
        window.showWindow(self)
        projectSelectionWindowController = window
        
        // Check if there is no station ID and provide a warning if so
        if defaults.object(forKey: "StationID") == nil {
            let alert = NSAlert()
            alert.messageText = "Warning"
            alert.informativeText = "The station ID has not been set for this computer. Please go into Cider > Preferences... and set one."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func debugPost(_ message: String) {
        if processWindowController != nil {
            processWindowController!.debugTextView.string.append("\(message)\n")
        }
    }
    
    @IBAction func preferenceSettingPressed(_ sender: NSMenuItem) {
        preferenceWindowController = PreferenceWindowController()
        preferenceWindowController?.showWindow(self)
    }
    
    @IBAction func startBtnPressed(_ sender: Any) {
        
        // Check if there is a station ID set and provide a warning to set one if there isn't
        if defaults.object(forKey: "StationID") != nil {
            
            if projectSelectionWindowController != nil {
                projectSelectionWindowController!.processWillStart = true
                projectSelectionWindowController!.close()
                
                dashboardWindowController = DashboardWindowController()
                dashboardWindowController!.processWindowController = processWindowController
                dashboardWindowController!.showWindow(self)
                dashboardWindowController!.processStarted()
                
                processWindowController = ProcessWindowController()
                processWindowController!.dashboardWindowController = dashboardWindowController
                processWindowController!.showWindow(self)
                processWindowController!.window?.orderOut(self)
            }
            
        } else {
            let alert = NSAlert()
            alert.messageText = "Warning"
            alert.informativeText = "The station ID has not been set for this computer. Please go into the preferences and set the station number before running the process."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        
    }
    
    @IBAction func showProcessBtnPressed(_ sender: NSButton) {
        if let processWindowController = self.processWindowController {
            processWindowController.window?.makeKeyAndOrderFront(self)
        }
        
    }
    
    @IBAction func scanAssetsBtnPressed(_ sender: NSButton) {
        assetScanWindowController = AssetScanWindowController()
        assetScanWindowController!.showWindow(self)
    }
    
    
}
