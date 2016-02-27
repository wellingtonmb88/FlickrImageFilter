//
//  ImageFeedTableViewController.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 2/26/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.

import UIKit

class ImageFeedTableViewController: UITableViewController { 
    
    var progress: UIActivityIndicatorView!
    var feedItem: FeedItem!
    var feed: Feed? {
        didSet {
            self.tableView.reloadData()
            progress.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        createProgress()
        updateFeeds("Earth")
    }
    
    //MARK: @IBAction Functions
    
    @IBAction func search(sender: AnyObject) {
        
        let alertController = AlertUtils.createAlertWithTextField("Search by Tag!", message: "Type your tag", okActionHandler: { (textFieldValue) -> Void in
            self.updateFeeds(textFieldValue)
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: Private Functions
    
    private func updateFeeds(tag: String){
        
        guard tag.characters.count > 0 else {
            self.errorMessage()
            return
        }
        
        progress.startAnimating()
        
        let urlString = "https://api.flickr.com/services/feeds/photos_public.gne?tags=\(tag)&format=json&nojsoncallback=1"
        
        if let url = NSURL(string: urlString) {
            NetworkUtils.updateFeed(url, completion: { (feed) -> Void in
                
                guard feed?.items.count > 0 else{
                    self.errorMessage()
                    return
                }
                self.feed = feed
            })
        }
    }
    
    private func errorMessage(){
        let alertController = AlertUtils.createAlert("Sorry !", message: "No feeds found!")
        self.presentViewController(alertController, animated: true, completion: nil)
        self.progress.stopAnimating()
    }
    
    private func createProgress(){
        progress = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        progress.center = self.view.convertPoint(self.view.center, fromView: self.view.superview)
        self.view.addSubview(progress)
    }
    
    //MARK: UITableViewDelegate
    
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
