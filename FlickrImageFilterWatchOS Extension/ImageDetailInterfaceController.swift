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
    
    @IBOutlet var imageTitle: WKInterfaceLabel!
    
    //MARK: LifeCycle
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let data = context!["data"] as? [[String : AnyObject]] else{
            return
        }
        guard let imgLabel = data[0]["dataLabel"] as? String else {
            return
        }
        
        guard let imgData = data[1]["dataImage"] as? UIImage else {
            return
        }
        
        self.imageDetail.setImage(imgData)
        self.imageTitle.setText(imgLabel)
        
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