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
    
    var images = [UIImage]()
    
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
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateTable(images: [UIImage]){
        imagesTable.setNumberOfRows(images.count, withRowType: "ImageRow")
        
        for index in 0..<imagesTable.numberOfRows {
            if let controller = imagesTable.rowControllerAtIndex(index) as? DownloadImageWK {
                let item = images[index]
                controller.imageViewInterface.setImage(item)
            }
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let image = self.images[rowIndex]
        presentControllerWithName("ImageDetails", context: image)
    }
    
    func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
        let image : UIImage = UIImage(data: messageData)!
        self.images.append(image)
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            
            var size: NSInteger = self.images.count
            let data = NSData(bytes: &size, length: sizeof(NSInteger))
            replyHandler(data)
        }

    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let status = applicationContext["status"] as? String
        
        switch status! {
        case "finished":
            //Use this to update the UI instantaneously (otherwise, takes a little while)
            dispatch_async(dispatch_get_main_queue()) {
                self.updateTable(self.images)
            }
                break
            case "clean" :
                self.images.removeAll()
                break
            default:
                break
        }
    }

}
