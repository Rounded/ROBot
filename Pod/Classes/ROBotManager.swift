//
// Created by Heather Snepenger on 3/25/15.
// Copyright (c) 2015 Rounded. All rights reserved.
//

import Foundation
import CoreData

@objc(ROBotManager)
public class ROBotManager {
    
    //    private var reachability:Reachability?
    
    public class func initialize(baseUrl: String, token: String) -> ROBotManager{
        return initialize(baseUrl, token: token, shouldCacheOffline: true, verboseLogging: true)
    }
    
    public class func initialize(baseUrl: String, token: String, shouldCacheOffline: Bool, verboseLogging: Bool) -> ROBotManager {
        ROBotManagedObject.baseURLString = baseUrl
        ROBotManagedObject.token = token
        //        ROBotManagedObject.persistentStoreCoordinator = storeCoordinator!
        ROBotManagedObject.shouldCacheOffline = shouldCacheOffline
        ROBotManagedObject.verboseLogging = verboseLogging
        
        var manager = ROBotManager()
        if shouldCacheOffline {
            //            manager.startReachability()
        }
        return manager
    }
    
    //    private func startReachability() {
    ////        NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkForReachability:", name: kReachabilityChangedNotification, object: nil);
    //
    //        NSNotificationCenter.defaultCenter().addObserverForName(kReachabilityChangedNotification, object: nil, queue: nil){ note in
    //            println("here")
    //        }
    //        self.reachability = Reachability.reachabilityForInternetConnection();
    //        self.reachability?.startNotifier();
    //
    //    }
    
    //    func checkForReachability(notification:NSNotification)
    //    {
    //        // Remove the next two lines of code. You cannot instantiate the object
    //        // you want to receive notifications from inside of the notification
    //        // handler that is meant for the notifications it emits.
    //
    //        //var networkReachability = Reachability.reachabilityForInternetConnection()
    //        //networkReachability.startNotifier()
    //
    //        let networkReachability = notification.object as Reachability;
    //        var remoteHostStatus = networkReachability.currentReachabilityStatus()
    //
    //        if (remoteHostStatus.value == NotReachable.value)
    //        {
    //            println("Not Reachable")
    //        }
    //        else if (remoteHostStatus.value == ReachableViaWiFi.value)
    //        {
    //            println("Reachable via Wifi")
    //        }
    //        else
    //        {
    //            println("Reachable")
    //        }
    //    }
    
    //    private func reachabilityChanged(note: NSNotification) {
    //
    //        if let reachability = note.object as? Reachability {
    //
    ////            if reachability.isReachable() {
    ////                if reachability.isReachableViaWiFi() {
    ////                    println("Reachable via WiFi")
    ////                } else {
    ////                    println("Reachable via Cellular")
    ////                }
    ////                ROBotManagedObject.uploadCachedData()
    ////            } else {
    ////                println("Not reachable")
    ////            }
    //        }
    //
    //    }
}