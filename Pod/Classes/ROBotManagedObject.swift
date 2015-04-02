//
// Created by Heather Snepenger on 3/24/15.
// Copyright (c) 2015 Rounded. All rights reserved.
//

import Foundation
import CoreData

@objc(ROBotManagedObject)
public class ROBotManagedObject : NSManagedObject {
    
    private struct DBdefaults {
        // default the primary key value to "id"
        static var pkValue : String = "id"
        //        static var mapping : Dictionary<String, String> = ["":""]
        static var indexUrl: String = ""
        static var shouldCacheOffline : Bool = true
        
        static var baseURLString : String = ""
        static var token : String = ""
        static var verboseLogging : Bool = false
        //        static var persistentStoreCoordinator : NSPersistentStoreCoordinator = NSPersistentStoreCoordinator()
    }
    
    private enum CRUD {
        case CREATE
        case READ
        case UPDATE
        case DELETE
    }
    
    class var pkValue: String
        {
        get { return DBdefaults.pkValue }
        set { DBdefaults.pkValue = newValue }
    }
    
//    class var indexUrl: String
//        {
//        get { return DBdefaults.indexUrl }
//        set { DBdefaults.indexUrl = newValue }
//    }
    
    //    class var mapping: Dictionary<String, String>
    //        {
    //        get { return DBdefaults.mapping }
    //        set { DBdefaults.mapping = newValue }
    //    }
    
    class var shouldCacheOffline: Bool
        {
        get { return DBdefaults.shouldCacheOffline }
        set { DBdefaults.shouldCacheOffline = newValue }
    }
    
    class var verboseLogging: Bool
        {
        get { return DBdefaults.verboseLogging }
        set { DBdefaults.verboseLogging = newValue }
    }
    
    //    class var persistentStoreCoordinator: NSPersistentStoreCoordinator
    //    {
    //        get { return DBdefaults.persistentStoreCoordinator }
    //        set { DBdefaults.persistentStoreCoordinator = newValue }
    //    }
    
    class var baseURLString: String
        {
        get { return DBdefaults.baseURLString }
        set { DBdefaults.baseURLString = newValue }
    }
    
    class var token: String
        {
        get { return DBdefaults.token }
        set { DBdefaults.token = newValue }
    }
    
    public class func indexUrl() -> String {
        fatalError("Did you forget to override the create url?")
        return ""
    }
    
    public func createUrl() -> String {
        fatalError("Did you forget to override the create url?")
        return ""
    }
    
    public func readUrl() -> String {
        fatalError("Did you forget to override the read url?")
        return ""
    }
    
    public func updateUrl() -> String {
        fatalError("Did you forget to override the update url?")
        return ""
    }
    
    public func deleteUrl() -> String {
        fatalError("Did you forget to override the delete url?")
        return ""
    }
    
    
    class func printResults(request: AnyObject?, response: AnyObject?, JSON: AnyObject?, error: AnyObject?) {
        
        println(request)
        println(response)
        println(JSON)
        println(error)
    }
    
    public class func index() {
        let URL = NSURL(string: ROBotManagedObject.baseURLString + self.indexUrl())!
        let mutableURLRequest : NSMutableURLRequest = NSMutableURLRequest(URL: URL)
        var session = NSURLSession.sharedSession()
        mutableURLRequest.HTTPMethod = "GET"
        mutableURLRequest.setValue("Bearer \(ROBotManagedObject.token)", forHTTPHeaderField: "Authorization")
        
        var task = session.dataTaskWithRequest(mutableURLRequest, completionHandler: {
            data, response, error -> Void in
                        
            if (ROBotManagedObject.verboseLogging) {
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                ROBotManagedObject.printResults(mutableURLRequest, response: response, JSON: strData, error: error)
            }
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                if (ROBotManagedObject.verboseLogging) {
                    println(err!.localizedDescription)
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: '\(jsonStr)'")
                }
            }
            else {
                // Save the updated results
                println("were back");
                println(json);
            }
        })
        task.resume()
    }
    
    public func create() {
        // create from server
        let URL = NSURL(string: ROBotManagedObject.baseURLString + createUrl())!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        var session = NSURLSession.sharedSession()
        var err: NSError?
        mutableURLRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(self.asDictionary(), options: nil, error: &err)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        mutableURLRequest.setValue("Bearer \(ROBotManagedObject.token)", forHTTPHeaderField: "Authorization")
        
        var task = session.dataTaskWithRequest(mutableURLRequest, completionHandler: {
            data, response, error -> Void in
            
            if (ROBotManagedObject.verboseLogging) {
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                ROBotManagedObject.printResults(mutableURLRequest, response: response, JSON: strData, error: error)
            }
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                if (ROBotManagedObject.verboseLogging) {
                    println(err!.localizedDescription)
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: '\(jsonStr)'")
                }
            }
            else {
                // Save the updated results
                if let dict = json as? Dictionary<String, AnyObject> {
                    self.save(dict)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
    }
    
    public func read() {
        
        // read from server
        let URL = NSURL(string: ROBotManagedObject.baseURLString + readUrl())!
        let mutableURLRequest : NSMutableURLRequest = NSMutableURLRequest(URL: URL)
        var session = NSURLSession.sharedSession()
        mutableURLRequest.HTTPMethod = "GET"
        mutableURLRequest.setValue("Bearer \(ROBotManagedObject.token)", forHTTPHeaderField: "Authorization")
        
        var task = session.dataTaskWithRequest(mutableURLRequest, completionHandler: {
            data, response, error -> Void in
            
            
            if (ROBotManagedObject.verboseLogging) {
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                ROBotManagedObject.printResults(mutableURLRequest, response: response, JSON: strData, error: error)
            }
            
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                if (ROBotManagedObject.verboseLogging) {
                    println(err!.localizedDescription)
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: '\(jsonStr)'")
                }
            }
            else {
                // Save the updated results
                if let dict = json as? Dictionary<String, AnyObject> {
                    self.save(dict)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
    }
    
    public func update() {
        // update to server
        let URL = NSURL(string: ROBotManagedObject.baseURLString + updateUrl())!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        var session = NSURLSession.sharedSession()
        var err: NSError?
        mutableURLRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(self.asDictionary(), options: nil, error: &err)
        mutableURLRequest.HTTPMethod = "PUT"
        mutableURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        mutableURLRequest.setValue("Bearer \(ROBotManagedObject.token)", forHTTPHeaderField: "Authorization")
        
        var task = session.dataTaskWithRequest(mutableURLRequest, completionHandler: {
            data, response, error -> Void in
            
            if (ROBotManagedObject.verboseLogging) {
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                ROBotManagedObject.printResults(mutableURLRequest, response: response, JSON: strData, error: error)
            }
            
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                if (ROBotManagedObject.verboseLogging) {
                    println(err!.localizedDescription)
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: '\(jsonStr)'")
                }
            }
            else {
                // Save the updated results
                if let dict = json as? Dictionary<String, AnyObject> {
                    self.save(dict)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
        
    }
    
    public func delete() {
        // delete from server
        let URL = NSURL(string: ROBotManagedObject.baseURLString + deleteUrl())!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        var session = NSURLSession.sharedSession()
        mutableURLRequest.HTTPMethod = "DELETE"
        mutableURLRequest.setValue("Bearer \(ROBotManagedObject.token)", forHTTPHeaderField: "Authorization")
        
        var task = session.dataTaskWithRequest(mutableURLRequest, completionHandler: {
            data, response, error -> Void in
            
            
            if (ROBotManagedObject.verboseLogging) {
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                ROBotManagedObject.printResults(mutableURLRequest, response: response, JSON: strData, error: error)
            }
            
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                if (ROBotManagedObject.verboseLogging) {
                    println(err!.localizedDescription)
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: '\(jsonStr)'")
                }
            }
            else {
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode == 200) {
                        // Delete the updated results
                        self.managedObjectContext?.deleteObject(self)
                        self.saveContext()
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                        println("Error could not parse JSON: \(jsonStr)")
                    }
                }
                
                
            }
        })
        task.resume()
        
    }
    
    private class func cacheType(crudType: CRUD) -> String {
        var cacheSlug : String = ""
        switch crudType {
        case .CREATE:
            cacheSlug = "create_cache"
        case .READ:
            cacheSlug = "read_cache"
        case .UPDATE:
            cacheSlug = "update_cache"
        case .DELETE:
            cacheSlug = "delete_cache"
        default:
            cacheSlug = "create_cache"
        }
        
        return cacheSlug
    }
    
    private func cacheOffline(crudType: CRUD) {
        
        // first save the object
        self.saveContext()
        let cacheSlug = ROBotManagedObject.cacheType(crudType)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        // get the array of saved ids from the defaults based on the cache type
        var ids = defaults.stringArrayForKey(cacheSlug) as [String]?
        if (ids == nil) {
            ids = [String]()
        }
        // add the new id to the array
        ids!.append(self.objectID.URIRepresentation().absoluteString as String!)
        defaults.setObject(ids, forKey: cacheSlug)
        defaults.synchronize()
    }
    
    //    class func uploadCachedData() {
    //
    //        let defaults = NSUserDefaults.standardUserDefaults()
    //
    //        let context = NSManagedObjectContext()
    //        context.persistentStoreCoordinator = ROBotManagedObject.persistentStoreCoordinator
    //
    //        var create_ids = defaults.stringArrayForKey(cacheType(.CREATE)) as [String]?
    //        if let ids = create_ids {
    //            for id in ids {
    //
    //                let idURL : NSURL! = NSURL(string: id)
    //                let moID : NSManagedObjectID! = persistentStoreCoordinator.managedObjectIDForURIRepresentation(idURL)
    //                var object = context.objectWithID(moID) as ROBotManagedObject
    //
    //                println(idURL)
    //                println(moID)
    //                println(object)
    //            }
    //        }
    //
    //    }
    
}