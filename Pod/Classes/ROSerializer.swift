//
//
//  Created by bw on 3/18/15.
//  Copyright (c) 2015 rounded. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    private struct DBdefaults {
        static var mapping : Dictionary<String, String> = ["":""]
    }

    class var mapping: Dictionary<String, String>
    {
        get { return DBdefaults.mapping }
        set { DBdefaults.mapping = newValue }
    }
    
    class func classString() -> String {
        return NSStringFromClass(self)
    }
    
    //    class func save(primaryKey: String, entityName: String, json: Dictionary<String, AnyObject>) {
    //
    //        // Create a context
    //        let context : NSManagedObjectContext! = NSManagedObjectContext()
    //        context.persistentStoreCoordinator = ROBotManagedObject.persistentStoreCoordinator
    //
    //        var err : NSErrorPointer = nil
    //        // I can't figure out how to the dynamically get the name of the entity in swift yet
    //        var fetchRequest = NSFetchRequest(entityName: entityName)
    //        println(json["first_name"])
    //        fetchRequest.predicate = NSPredicate(format: "%K = %@", primaryKey, json[primaryKey] as NSNumber)
    //        println(fetchRequest.predicate)
    //        var objects = context!.executeFetchRequest(fetchRequest, error: err) as [ROBotManagedObject]?
    //
    //        println(objects)
    //
    //        if let results = objects{//(objects?.count > 0) {
    //            if (results.count > 0) {
    //                // Use the first object that matches the primary key
    //                let object : ROBotManagedObject = results[0]
    //
    //                // pull out the attributes that exist in the database
    //                var entity : NSEntityDescription = object.entity
    //                var attributes = entity.attributesByName as [String: NSAttributeDescription]
    //
    //                // Update all the key / values for the object
    //                for (key, value) in json {
    //                    // If the values exists in the mapping, use the mapping
    //                    if let newKey = ROBotManagedObject.mapping[key] {
    //                        object.setValue(value, forKey: newKey)
    //                    } else if let attribValue = attributes[key]{
    //                        // if the attibute value exists in the database, add it
    //                        object.setValue(value, forKey: key)
    //                    }
    //                }
    //
    //                // Save to disk
    //                object.saveContext()
    //            }
    //
    //        } else {
    //            let object = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context!) as ROBotManagedObject
    //            object.save(json)
    //        }
    //
    //    }


    // updates the values without saving to the database. Use this method to do batch operations
    func update(json: Dictionary<String, AnyObject>) {
        // pull out the attributes that exist in the database
        var entity : NSEntityDescription = self.entity
        var attributes = entity.attributesByName as [String: NSAttributeDescription]

        // Update all the key / values for the object
        for (key, value) in json {
            // If the values exists in the mapping, use the mapping
            if let newKey = NSManagedObject.mapping[key] {
                self.setValue(value, forKey: newKey)
            } else if let attribValue = attributes[key]{
                // if the attibute value exists in the database, add it
                self.setValue(value, forKey: key)
            }
        }

    }

    func save(json: Dictionary<String, AnyObject>) -> NSManagedObject {

        // Update the values
        update(json)

        // Save to disk
        saveContext()
        
        return self
    }
    
    func saveContext() {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func asDictionary() -> [String: AnyObject] {
        
        var dictionary = Dictionary<String, AnyObject>()
        
        var attributes = entity.attributesByName as [String: NSAttributeDescription]
        
        for (key, value) in attributes {
            dictionary[key] = self.valueForKey(key)
        }
        
        //        for (key, value) in ROBotManagedObject.mapping {
        //            dictionary[key] = self.valueForKey(key)
        //        }
        
        return dictionary
    }
    
}