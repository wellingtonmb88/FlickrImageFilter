//
//  FeedDetailsViewController.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 2/27/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import UIKit

class FeedDatailsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var detailImage: DownloadImageView!
    @IBOutlet weak var detailName: UILabel!
    @IBOutlet weak var zoomGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var feedItem: FeedItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.detailName.text = self.feedItem.title
        
        self.detailImage.setUrl(self.feedItem.imageURL.absoluteString)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: @IBAction Functions
    
    @IBAction func openImageFilterTool(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "FilterMain", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("FilterMainViewController") as! FilterMainViewController
        
        vc.imageOriginal = self.detailImage.image
        vc.feedItem = self.feedItem
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addTagToFeedItem(sender: AnyObject) {
        
        let alertController = AlertUtils.createAlertWithTextField("Add Tag", message: "Type your tag") { (textFieldValue) -> Void in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.dataController.tagFeedItem(textFieldValue, feedItem: self.feedItem)
        }
        
        self.presentViewController(alertController, animated: false, completion: nil)
    }
    
    @IBAction func onTap(sender: AnyObject) {
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollView.zoomScale = 1.5 * self.scrollView.zoomScale
        }
    } 
    
    //MARK: UIScrollView Delegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.detailImage
    }
}