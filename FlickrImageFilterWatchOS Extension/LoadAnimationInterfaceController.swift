//
//  LoadAnimationInterfaceController.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 3/2/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class LoadAnimationInterfaceController: WKInterfaceController, WCSessionDelegate, ImagesInterfaceControllerDelegate {
    
    @IBOutlet var mainGroup: WKInterfaceGroup!
    @IBOutlet var circleGroupRed: WKInterfaceGroup!
    @IBOutlet var circleGroupBlue: WKInterfaceGroup!
    @IBOutlet var circleGroupGreen: WKInterfaceGroup!
    
    var shouldStoAnimation: Bool = false
    var session: WCSession!
    var watchDatas = [Int: WatchData]()
    var totalDataSize: Int = 0
    
    //MARK: LifeCycle
    
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
        
        self.mainGroup.startAnimatingWithImagesInRange(NSRange(location: 0, length: 11), duration: 1.3, repeatCount: Int.max)
        
        startAnimation()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //MARK: WCSessionDelegate

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
        if let size = message["dataSize"] as? Int {
            self.totalDataSize = size
            self.watchDatas.removeAll()
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            
            guard let data = applicationContext["data"] as? [[String : AnyObject]] else{
                return
            }
            
            guard let dataPosition = data[0]["dataPosition"] as? Int else {
                return
            }
            
            guard let imgLabel = data[1]["dataLabel"] as? String else {
                return
            }
            
            guard let imgData = data[2]["dataImage"] as? NSData else {
                return
            }
            
            let watchData = WatchData(imageData: imgData, imagePosition: dataPosition, imageLabel: imgLabel)
            self.updateImages(watchData)
        }
    }
    
    //MARK: ImagesInterfaceControllerDelegate
    func getWatchData() -> [Int: WatchData] {
        return self.watchDatas
    }
   
    //MARK: Private Functions
    
    private func updateImages(watchData: WatchData){
        self.watchDatas.updateValue(watchData, forKey: watchData.imagePosition)
        if self.watchDatas.count == totalDataSize {
            shouldStoAnimation = true
            self.pushControllerWithName("ImagesTable", context: self)
        }
    }
    
    private func startAnimation(){
    
        if !shouldStoAnimation {
            
            self.animateWithDuration(0.2) { () -> Void in
                self.circleGroupRed.setHorizontalAlignment(.Right)
                
            }
            
            delay(0.3) {
                self.animateWithDuration(0.3) { () -> Void in
                    self.circleGroupRed.setVerticalAlignment(.Bottom)
                }
            }
            
            delay(0.5) {
                self.animateWithDuration(0.3) { () -> Void in
                    self.circleGroupBlue.setHorizontalAlignment(.Right)
                }
            }
            
            delay(0.6) {
                self.animateWithDuration(0.3) { () -> Void in
                    self.circleGroupRed.setHorizontalAlignment(.Left)
                }
            }
            
            delay(0.7) {
                self.animateWithDuration(0.3) { () -> Void in
                    self.circleGroupBlue.setVerticalAlignment(.Bottom)
                }
            }
            
            delay(0.7) {
                self.animateWithDuration(0.3) { () -> Void in
                    self.circleGroupGreen.setHorizontalAlignment(.Right)
                }
            }
            
            delay(0.8) {
                self.animateWithDuration(0.3) { () -> Void in
                    self.circleGroupRed.setVerticalAlignment(.Top)
                }
            }
            
            delay(0.9) {
                self.animateWithDuration(0.3) { () -> Void in
                    self.circleGroupBlue.setHorizontalAlignment(.Left)
                }
            }
            
            delay(1) {
                self.animateWithDuration(0.3) { () -> Void in
                    self.circleGroupGreen.setVerticalAlignment(.Bottom)
                }
            }
            
            delay(1.1) {
                self.animateWithDuration(0.3) { () -> Void in
                    self.circleGroupBlue.setVerticalAlignment(.Top)
                }
            }
            
            delay(1.2) {
                self.animateWithDuration(0.3) { () -> Void in
                    self.circleGroupGreen.setHorizontalAlignment(.Left)
                }
            }
            
            delay(1.5) {
                self.animateWithDuration(0.3) { () -> Void in
                    self.circleGroupGreen.setVerticalAlignment(.Top)
                    self.startAnimation()
                }
            }
        }
        
    }
    
    func delay(delay: NSTimeInterval, closure:() -> ()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
}