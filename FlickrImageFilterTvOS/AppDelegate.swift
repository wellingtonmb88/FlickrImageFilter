//
//  AppDelegate.swift
//  PhotosTV
//
//  Created by Mike Spears on 2016-01-11.
//  Copyright © 2016 YourOganisation. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // We created these methods in the module on Persistence and Networking
    
    func feedFilePath() -> String {
        let paths = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        let filePath = paths[0].URLByAppendingPathComponent("feedFile.plist")
        return filePath.path!
    }
    
    func saveFeed(feed: Feed) -> Bool {
        let success = NSKeyedArchiver.archiveRootObject(feed, toFile: feedFilePath())
        assert(success, "failed to write archive")
        return success
    }
    
    func readFeed(completion: (feed: Feed?) -> Void) {
        let path = feedFilePath()
        let unarchivedObject = NSKeyedUnarchiver.unarchiveObjectWithFile(path)
        completion(feed: unarchivedObject as? Feed)
    }
    
    
    func loadOrUpdateFeed(url: NSURL, completion: (feed: Feed?) -> Void) {
        
        let lastUpdatedSetting = NSUserDefaults.standardUserDefaults().objectForKey("lastUpdate") as? NSDate
        
        var shouldUpdate = true
        if let lastUpdated = lastUpdatedSetting where NSDate().timeIntervalSinceDate(lastUpdated) < 20 {
            shouldUpdate = false
        }
        if shouldUpdate {
            self.updateFeed(url, completion: completion)
        } else {
            self.readFeed { (feed) -> Void in
                if let foundSavedFeed = feed where foundSavedFeed.sourceURL.absoluteString == url.absoluteString {
                    print("loaded saved feed!")
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        completion(feed: foundSavedFeed)
                    })
                } else {
                    self.updateFeed(url, completion: completion)
                }
            }
        }
    }
    
    func updateFeed(url: NSURL, completion: (feed: Feed?) -> Void) {
        let request = NSURLRequest(URL: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error == nil && data != nil {
                let feed = Feed(data: data!, sourceURL: url)
                
                if let goodFeed = feed {
                    if self.saveFeed(goodFeed) {
                        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastUpdate")
                    }
                }
                
                print("loaded Remote feed!")
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completion(feed: feed)
                })
            }
            
        }
        
        task.resume()
    }
}

