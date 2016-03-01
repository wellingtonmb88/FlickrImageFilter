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
    
    //MARK: Download all Image data From Feed
    static func downloadAllImageDataFromFeed(feedItems: [FeedItem], completion: (batchData:[NSData]) -> Void){
        
        NSOperationQueue().addOperationWithBlock({
            var dataBatch: [NSData] = []
            for feedItem in feedItems {
                let data = NSData(contentsOfURL: NSURL(string: feedItem.imageURL.absoluteString)!)!
                dataBatch.append(data)
            }
            
            completion(batchData: dataBatch)
        })
    }
}