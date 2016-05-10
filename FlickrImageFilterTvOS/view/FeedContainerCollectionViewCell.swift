//
//  FeedContainerCollectionViewCell.swift
//  FirstTV
//
//  Created by Mike Spears on 2016-01-11.
//  Copyright © 2016 YourOganisation. All rights reserved.
//

import UIKit

class FeedContainerCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView?

    
    var feed: Feed?  {
        didSet {
            self.collectionView?.reloadData()
        }
    }

    override var preferredFocusedView: UIView? {
        return collectionView
    }
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.feed?.items.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        let item = self.feed!.items[indexPath.row]
        
        cell.title.text = item.title
        
        cell.imageView.setUrl(item.imageURL.absoluteString)
        
//        let request = NSURLRequest(URL: item.imageURL)
        
//        cell.dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
//            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//                if error == nil && data != nil {
//                    let image = UIImage(data: data!)
//                    cell.imageView.image = image
//                }
//            })
//            
//        }
//        
//        cell.dataTask?.resume()
        
        
        
        return cell
    }
    
//    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        if let cell = cell as? ImageCollectionViewCell {
//            cell.dataTask?.cancel()
//        }
//    }
//    

    

}
