//
//  ProjectSelectionModel.swift
//  Cider
//
//  Created by Gabriel Perez on 6/14/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Foundation

protocol ProjectManagerProtocol: class {
    func itemsDownloaded(items: NSArray)
}

class ProjectManager: NSObject, URLSessionDataDelegate {
    weak var delegate: ProjectManagerProtocol!
    
    static var selectedProject: Project?
    
    var data = Data()
    
    let urlPath = "https://dynamic-music-208223.appspot.com/"
    
    func downloadItems() {
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Failed to download data")
            }else {
                print("Data downloaded")
                self.parseJSON(data!)
            }
            
        }
        
        task.resume()
        
        defaultSession.finishTasksAndInvalidate()
    }
    
    func parseJSON(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        } catch let error as NSError {
            print(error)
        }
        
        var jsonElement = NSDictionary()
        let projects = NSMutableArray()
        
        for i in 0..<jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            
            if let id = jsonElement["id"] as? String,
                let name = jsonElement["name"] as? String
            {
                // Boolean values
                let restoring = (jsonElement["restore"] as? String == "1")
                let preparing = (jsonElement["prepare"] as? String == "1")
                let enrolling = (jsonElement["enroll"] as? String == "1")
                let installApps = (jsonElement["install_apps"] as? String == "1")
                let selfShutdown = (jsonElement["self_shutdown"] as? String == "1")
                
                // String values
                let depUsername = jsonElement["dep_username"] as? String
                let depPassword = jsonElement["dep_password"] as? String
                let appChecksum = jsonElement["app_checksum"] as? String
                
                projects.add(Project(name: name,
                                     id: id,
                                     restoring: restoring,
                                     preparing: preparing,
                                     enrolling: enrolling,
                                     depUsername: depUsername,
                                     depPassword: depPassword,
                                     installApps: installApps,
                                     appChecksum: appChecksum,
                                     selfShutdown: selfShutdown))
            }
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.delegate.itemsDownloaded(items: projects)
            
        })
    }
}
