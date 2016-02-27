//
//  FeedDetailsViewController.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 2/27/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import UIKit

class FeedDatailsViewController: UIViewController {
    
    @IBOutlet weak var detailImage: DownloadImageView!
    
    @IBOutlet weak var detailName: UILabel!
    
    var feedItem: FeedItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.detailName.text = self.feedItem.title
        
        self.detailImage.setUrl(self.feedItem.imageURL.absoluteString)
    }
    
    
    @IBAction func openImageFilterTool(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "FilterMain", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("FilterMainViewController") as! FilterMainViewController
        
        vc.imageOriginal = self.detailImage.image
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}