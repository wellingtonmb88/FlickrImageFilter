//
//  InterfaceController.swift
//  FlickrImageFilterWatchOS Extension
//
//  Created by WELLINGTON BARBOSA on 2/29/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation


class ImagesInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var imagesTable: WKInterfaceTable!
    var session: WCSession!
    
    var images = [Int: UIImage]()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        updateTable()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateTable(){
        for index in 0..<self.images.count {
            if let controller = imagesTable.rowControllerAtIndex(index) as? ImageViewInterfaceController {
                let image = self.images[index]
                controller.imageViewInterface.setImage(image)
            }
        }
    }
    
    func updateImages(dataPosition: Int, imageData:NSData){
        let image : UIImage = UIImage(data: imageData)!
        self.images.updateValue(image, forKey: dataPosition)
        if let controller = imagesTable.rowControllerAtIndex(dataPosition) as? ImageViewInterfaceController {
            controller.imageViewInterface.setImage(image)
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        
        let image = self.images[rowIndex]
        presentControllerWithName("ImageDetails", context: image)
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {

        if let size = message["dataSize"] as? Int {
            self.imagesTable.setNumberOfRows(size, withRowType: "ImageRow")
            self.images.removeAll()
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
       
        
        guard let data = applicationContext["data"] as? [[String : AnyObject]] else{
            return
        }
        
        guard let dataPosition = data[0]["dataPosition"] as? Int else {
            return
        }
        
        guard let imgData = data[1]["dataImage"] as? NSData else {
            return
        }
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) { 
            self.updateImages(dataPosition, imageData: imgData)
        }
    }

}
