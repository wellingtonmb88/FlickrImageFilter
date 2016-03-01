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
                self.feed = feed
            })
        }
    }
    
    //MARK: Private Functions
    
    private func sendFeedToWatchOS(){
        let applicationDict = ["status":"clean"]
        self.updateApplicationContextWatchOS(applicationDict)
        
        let feedItems = self.feed?.items
        
            NetworkUtils.downloadAllImageDataFromFeed(feedItems!) { (batchData) -> Void in
                
                for data in batchData {
                    self.session.sendMessageData(data, replyHandler: { (data) -> Void in
                        
                        var size: NSInteger = 0
                        
                        data.getBytes(&size, length: sizeof(NSInteger))
                        print(size)
                        
                        if size == batchData.count{
                            let applicationDict = ["status":"finished"]
                            self.updateApplicationContextWatchOS(applicationDict)
                        }
                        
                        }, errorHandler: { (error) -> Void in
                            print(error)
                    })
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
