//
//  ImageFeedTableViewController.swift
//  PhotoFeed
//
//  Created by WELLINGTON BARBOSA on 2/26/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.

import UIKit

class ImageFeedTableViewController: UITableViewController {

    var feed: Feed? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var feedItem: FeedItem!

    var urlSession: NSURLSession!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.urlSession = NSURLSession(configuration: configuration)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.urlSession.invalidateAndCancel()
        self.urlSession = nil
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feed?.items.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ImageFeedItemTableViewCell", forIndexPath: indexPath) as! ImageFeedItemTableViewCell
        
        let item = self.feed!.items[indexPath.row]
        cell.itemTitle.text = item.title


        
        let request = NSURLRequest(URL: item.imageURL)
        
        cell.dataTask = self.urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if error == nil && data != nil {
                    let image = UIImage(data: data!)
                    cell.itemImageView.image = image
                }
            })
            
        }
        
        
        
        cell.dataTask?.resume()
        
        return cell
    }
  
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? ImageFeedItemTableViewCell {
            cell.dataTask?.cancel()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "feedDetailsSegue" {
           let destination = segue.destinationViewController as? FeedDatailsViewController
            let indexRow = self.tableView.indexPathForSelectedRow?.row
            
            destination?.feedItem = self.feed!.items[indexRow!]
        }
    }

}
