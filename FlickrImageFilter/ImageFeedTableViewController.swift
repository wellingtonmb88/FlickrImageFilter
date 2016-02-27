//
//  ImageFeedTableViewController.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 2/26/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.

import UIKit

class ImageFeedTableViewController: UITableViewController { 
    
    var progress: UIActivityIndicatorView!
    
    var feed: Feed? {
        didSet {
            self.tableView.reloadData()
            progress.stopAnimating()
        }
    }
    
    var feedItem: FeedItem!
 
    func createProgress(){
        progress = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        progress.center = self.tableView.convertPoint(self.tableView.center, fromView: self.tableView.superview)
        self.tableView.addSubview(progress)
    }
    
    override func viewDidLoad() {
        let urlString = "https://api.flickr.com/services/feeds/photos_public.gne?tags=skateboard&format=json&nojsoncallback=1" //
        print(urlString)
        createProgress()

        
        progress.startAnimating()
        if let url = NSURL(string: urlString) {
            NetworkUtils.updateFeed(url, completion: { (feed) -> Void in
                self.feed = feed
            })
        }

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
        cell.itemImageView.setUrl(item.imageURL.absoluteString)
        
        return cell
    } 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "feedDetailsSegue" {
           let destination = segue.destinationViewController as? FeedDatailsViewController
            let indexRow = self.tableView.indexPathForSelectedRow?.row
            destination?.feedItem = self.feed!.items[indexRow!]
        }
    }

}
