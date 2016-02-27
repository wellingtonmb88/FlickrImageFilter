//
//  FeedDetailsViewController.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 2/27/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import UIKit

class FeedDatailsViewController: UIViewController {
    
    @IBOutlet weak var feedImage: UIImageView!
    
    @IBOutlet weak var feedName: UILabel!
    
    var feedItem: FeedItem!
    
    var urlSession: NSURLSession!
    var dataTask: NSURLSessionDataTask! 
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.urlSession.invalidateAndCancel()
        self.urlSession = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.urlSession = NSURLSession(configuration: configuration)
        
        feedName.text = self.feedItem.title
        
        let request = NSURLRequest(URL: self.feedItem.imageURL)
        
        dataTask = self.urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if error == nil && data != nil {
                    let image = UIImage(data: data!)
                    self.feedImage.image = image
                }
            })
            
        }
        
        dataTask.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}