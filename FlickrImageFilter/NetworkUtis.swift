//
//  NetworkUtis.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 2/27/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit

struct NetworkUtils {
    
    //MARK: Update Feed Request
    static func updateFeed(url: NSURL, completion: (feed: Feed?) -> Void) {
        let request = NSURLRequest(URL: url)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error == nil && data != nil {
                let feed = Feed(data: data!, sourceURL: url)
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completion(feed: feed)
                })
            } else {
                completion(feed: nil)
            }
            
        }
        
        task.resume()
    } 
}