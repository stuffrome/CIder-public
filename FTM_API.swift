//
//  FTM_API.swift
//  Cider
//
//  Created by Gabriel Perez on 7/1/18.
//  Copyright © 2018 Gabriel Perez. All rights reserved.
//

import Foundation

enum FTM_Field: String {
    case isSupervised = "isSupervised"
    case configurationProfiles = "configurationProfiles"
    case appCheck = "appCheck"
    case tetheredCache = "tetheredCache"
    case appCount = "appCount"
    case provStation = "provStation"
    case provState = "provState"
    case UDID = "UDID"
    case AssetTag = "Asset%20Tag"
    case WiFiMAC = "WiFi%20MAC"
    case BTMAC = "BT%20MAC"
    case BatCapacity = "Bat%20Capacity"
    case iOS = "iOS"
    case depUser = "depUser"
    case depPwd = "depPwd"
    case dep = "dep"
    case ECID = "ECID"
    case DeviceType = "Device%20Type"
}

enum FTM_WO_STATUS: String {
    case Active = "active"
    case Pending = "pending"
    case PendingShip = "pending%20ship"
}

class FTM_Handle: NSObject, URLSessionDataDelegate {
    fileprivate static let api = "https://ftmapi01.nfrastructure.com:8443"
    fileprivate static let key = ""
    
    fileprivate static func parseJSON(_ data: Data) -> [String:Any] {
        var items: [String:Any] = [:]
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        } catch let error as NSError {
            print(error)
        }
        
        var jsonElement = NSDictionary()
        
        for i in 0..<jsonResult.count
        {
            jsonElement = jsonResult[i] as! NSDictionary
            
            for key in jsonElement.allKeys {
                if let k = (key as? String) {
                    items[k] = jsonElement[key]
                }
            }
        }
        
        return items
    }
    
    // Looks for a work order in FTM
    static func findWO(for serial: String, in pid: String, completion: @escaping (Int?) -> Void) {
        print("findWO called")
        
        guard let url = URL(string: "\(api)/findwobylabel?key=\(key)&label=\(serial)&PID=\(pid)") else { return }
        let urlRequest = URLRequest(url: url)
        let defaultSession = URLSession(configuration: .default)
        
        print(url.absoluteString)
        
        let task = defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            
            if error != nil {
                print("WO could not be found!")
                completion(nil)
            }else {
                let items = parseJSON(data!)
                completion(items["WID"] as? Int)
            }
            
        }
        
        task.resume()
        
        defaultSession.finishTasksAndInvalidate()
    }
    
    // Creates a work order in FTM
    static func createWO(forSerial serial: String, inPID pid: String, completion: @escaping (Int?) -> Void) {
        let url = URL(string: "\(api)/createWO/\(pid)?key=\(key)&wLabel=\(serial)")!
        let defaultSession = URLSession(configuration: .default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Failed to create WO!")
                completion(nil)
            }else {
                var jsonResult = NSDictionary()
                
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                } catch let error as NSError {
                    print(error)
                }
                
                completion(jsonResult["return"] as? Int)
            }
            
        }
        
        task.resume()
        
        defaultSession.finishTasksAndInvalidate()
    }
    
    static func updateStatus(forWID wid: Int, to status: FTM_WO_STATUS) {
        let url = URL(string: "\(api)/updateStatus?key=\(key)&WID=\(wid)&newStatus=\(status.rawValue)")!
        let urlRequest = URLRequest(url: url)
        let defaultSession = URLSession(configuration: .default)
        
        let task = defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            
            if error != nil {
                print("Failed to change status!")
            }else {
                // Success
            }
            
        }
        
        task.resume()
        
        defaultSession.finishTasksAndInvalidate()
    }
    
    static func get(field: FTM_Field, forWID wid: Int, completion: @escaping (String?) -> Void) {
        let url = URL(string: "\(api)/getcustomfields?key=\(key)&WID=\(wid)&fld=\(field.rawValue)")!
        let defaultSession = URLSession(configuration: .default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Failed to retrieve data!")
                completion(nil)
            }else {
                let items = parseJSON(data!)
                completion(items["fieldVal"] as? String)
            }
            
        }
        
        task.resume()
        
        defaultSession.finishTasksAndInvalidate()
    }
    
    static func post(field: FTM_Field, value: String, forWID wid: Int) {
        let url = URL(string: "\(api)/setcustomfield?key=\(key)&WID=\(wid)&fld=\(field.rawValue)&val=\(value)")!
        let defaultSession = URLSession(configuration: .default)
            
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Failed to post data!")
            }else {
                // Success
            }
            
        }
        
        task.resume()
        
        defaultSession.finishTasksAndInvalidate()
    }
    
}
