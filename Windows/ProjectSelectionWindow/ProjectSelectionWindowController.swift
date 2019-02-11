//
//  ProjectSelectionWindowController.swift
//  Cider
//
//  Created by Gabriel Perez on 6/8/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Cocoa

class ProjectSelectionWindowController: NSWindowController, NSWindowDelegate {
    @IBOutlet weak var tableView: NSTableView!
    
    // Holds the projects returned from the database
    var feedItems: NSArray = NSArray()
    
    // Indicates whether a process was selected and will be initiated
    var processWillStart: Bool = false
    
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name(rawValue: "ProjectSelectionWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Table view setup
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Project manager setup
        let projectManager = ProjectManager()
        projectManager.delegate = self
        projectManager.downloadItems()  // Get projects from database
        
    }
    
    func windowWillClose(_ notification: Notification) {
        if !processWillStart {
            NSApplication.shared.terminate(self)
        }
    }
    
}

extension ProjectSelectionWindowController: ProjectManagerProtocol {
    func itemsDownloaded(items: NSArray) {
        feedItems = items
        self.tableView.reloadData()
    }
}

extension ProjectSelectionWindowController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return feedItems.count
    }
}

extension ProjectSelectionWindowController: NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let ProjectName = NSUserInterfaceItemIdentifier(rawValue: "projectName")
        static let ProjectID = NSUserInterfaceItemIdentifier(rawValue: "pid")
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: NSUserInterfaceItemIdentifier?
        
        let project = feedItems[row] as? Project
        
        if project != nil {
            if tableColumn == tableView.tableColumns[0] {
                text = project!.name
                cellIdentifier = CellIdentifiers.ProjectName
            }
            else if tableColumn == tableView.tableColumns[1] {
                text = String(project!.id)
                cellIdentifier = CellIdentifiers.ProjectID
            }
        }
        
        if let cell = tableView.makeView(withIdentifier: cellIdentifier!, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        ProjectManager.selectedProject = feedItems[tableView.selectedRow] as? Project
    }
}
