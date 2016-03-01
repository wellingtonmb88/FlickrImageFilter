//
//  ImageDetailInterfaceController.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 2/29/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import WatchKit
import Foundation


class ImageDetailInterfaceController: WKInterfaceController {
    
    @IBOutlet var imageDetail: WKInterfaceImage!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let image = context as? UIImage {
            self.imageDetail.setImage(image)
        } 
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}