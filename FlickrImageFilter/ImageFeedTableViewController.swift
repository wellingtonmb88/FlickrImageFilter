//
//  ImageFeedTableViewController.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 2/26/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.

import UIKit
import CoreData
import WatchConnectivity

class ImageFeedTableViewController: UITableViewController, WCSessionDelegate {
    
    var progress: UIActivityIndicatorView?
    var session: WCSession!
    var lastTag: String!
    var isFeedsTable: Bool = false
    
    var feed: Feed? {
        didSet {
            self.tableView.reloadData()
            progress?.stopAnimating()
            sendFeedToWatchOS()
        }
    }
    
    override func viewDidLoad() {
        createProgress()
        
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        } 
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let title = self.navigationItem.title {
            if title == "Feeds" {
                isFeedsTable = true
            }else {
                isFeedsTable = false
            }
        }else {
            isFeedsTable = false
        }
    }
    
    //MARK: @IBAction Functions
    
    @IBAction func search(sender: AnyObject) {
        
        let alertController = AlertUtils.createAlertWithTextField("Search by Tag!", message: "Type your tag", okActionHandler: { (textFieldValue) -> Void in
           let text = textFieldValue.stringByReplacingOccurrencesOfString(" ", withString: "",
                options: NSStringCompareOptions.LiteralSearch, range: nil)
            self.updateFeeds(text)
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func updateFeeds(tag: String){
        
        self.progress?.startAnimating()
        guard tag.characters.count > 0 else {
            self.errorMessage()
            return
        }
        
        let urlString = "https://api.flickr.com/services/feeds/photos_public.gne?tags=\(tag)&format=json&nojsoncallback=1"
        
        if let url = NSURL(string: urlString) {
            NetworkUtils.updateFeed(url, completion: { (feed) -> Void in
                
                guard feed?.items.count > 0 else{
                    self.errorMessage()
                    return
                }
                if self.lastTag != tag {
                    self.feed = feed
                    self.lastTag = tag
                } else {
                    self.progress?.stopAnimating()
                }
            })
        }
    }
    
    //MARK: WatchOS Functions 
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        let response = message["update"] as! String
        if response == "yes" && isFeedsTable {
            sendFeedToWatchOS()
        } else {
            replyHandler(["replyHandler": "Error"])
        }
    }
    
    func sendFeedToWatchOS(){
        
        let feedItems = self.feed?.items
        
        if feedItems?.count > 0 && isFeedsTable{
            let dataSize = ["dataSize": feedItems!.count]
            session.sendMessage(dataSize, replyHandler: nil, errorHandler: nil)
            
            self.downloadAllImageDataFromFeed(feedItems!) { (position, imgData) -> Void in
                
                //Use this to update the UI instantaneously (otherwise, takes a little while)
                dispatch_async(dispatch_get_main_queue()) {
                    let applicationDict = ["data": [["dataPosition":position], ["dataLabel":feedItems![position].title], ["dataImage":imgData]]]
                    self.updateApplicationContextWatchOS(applicationDict)
                }
            }
        }
    }
    
    private func updateApplicationContextWatchOS(applicationDict: [String: AnyObject]){
        do {
            try self.session.updateApplicationContext(applicationDict)
        } catch {
            print("error")
        }
    }
    
    
    private func downloadAllImageDataFromFeed(feedItems: [FeedItem], completion: (position: Int, imgData:NSData) -> Void){
        
        for index in 0..<feedItems.count {
            NSOperationQueue().addOperationWithBlock({
                let data = NSData(contentsOfURL: NSURL(string: feedItems[index].imageURL.absoluteString)!)!
                
                completion(position:index, imgData: data)
            })
        }
    }
    
    //MARK: Private Functions
    
    private func errorMessage(){
        let alertController = AlertUtils.createAlert("Sorry !", message: "No feeds found!")
        self.presentViewController(alertController, animated: true, completion: nil)
        self.progress?.stopAnimating()
    }
    
    private func createProgress(){
        self.progress = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.progress?.center = self.view.convertPoint(self.view.center, fromView: self.view.superview)
        self.view.addSubview(progress!)
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
        if item.isFiltered == 1 {
            cell.itemImageView.downlaodCachedFilteredImg(item.imageURL.absoluteString)
        } else {
            cell.itemImageView.setUrl(item.imageURL.absoluteString)
        }
        
        return cell
    } 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "feedDetailsSegue" {
           let destination = segue.destinationViewController as? FeedDatailsViewController
            let indexRow = self.tableView.indexPathForSelectedRow?.row
            destination?.feedItem = self.feed!.items[indexRow!]
        } else if segue.identifier == "showTags" {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let moc = appDelegate.dataController.managedObjectContext
            
            let tagsVC = segue.destinationViewController as! TagsTableViewController
            
            let request = NSFetchRequest(entityName: "Tag")
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            tagsVC.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil) 
        }
    }

}
