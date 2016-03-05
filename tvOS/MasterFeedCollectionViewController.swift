//
//  MasterFeedCollectionViewController.swift
//  FirstTV
//
//  Created by Mike Spears on 2016-01-11.
//  Copyright © 2016 YourOganisation. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MasterFeedCollectionViewController: UICollectionViewController {

    var feeds = [Feed]()
    let urls = [
        "https://api.flickr.com/services/feeds/photos_public.gne?tags=kitten&format=json&nojsoncallback=1",
        "https://api.flickr.com/services/feeds/photos_public.gne?tags=pug&format=json&nojsoncallback=1",
        "https://api.flickr.com/services/feeds/photos_public.gne?tags=pizza&format=json&nojsoncallback=1"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        for urlString in urls {
            if let url = NSURL(string: urlString) {
                appDelegate.loadOrUpdateFeed(url, completion: { (feed) -> Void in
                    if feed != nil {
                        self.feeds.append(feed!)
                    }
                    self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: self.feeds.count - 1, inSection: 0)])
                    
                })
            }
        }
    }



    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feeds.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ContainerCell", forIndexPath: indexPath) as! FeedContainerCollectionViewCell
        
        cell.feed = self.feeds[indexPath.row]
    
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {

        return false
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailViewController = segue.destinationViewController as! DetailViewController

        if let focusedCell = UIScreen.mainScreen().focusedView as? ImageCollectionViewCell {
            detailViewController.image = focusedCell.imageView.image
            detailViewController.title = focusedCell.title.text
        }
    }

}
