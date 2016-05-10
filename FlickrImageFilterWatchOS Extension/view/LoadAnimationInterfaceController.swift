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

protocol LoadAnimationInterfaceControllerDelegate {
    func updateData() 
}

class LoadAnimationInterfaceController: WKInterfaceController, WCSessionDelegate, ImagesInterfaceControllerDelegate {
    
    @IBOutlet var connectionStatusLabel: WKInterfaceLabel!
    
    @IBOutlet var mainGroup: WKInterfaceGroup!
    @IBOutlet var circleGroupRed: WKInterfaceGroup!
    @IBOutlet var circleGroupBlue: WKInterfaceGroup!
    @IBOutlet var circleGroupGreen: WKInterfaceGroup!
    
    var delegate: LoadAnimationInterfaceControllerDelegate?
    var shouldStopAnimation: Bool = false
    var session: WCSession!
    var watchDatas = [Int: WatchData]()
    var totalDataSize: Int = 0
    var shouldShowFirstAlert: Bool = true
    var shouldShowUpdateAlert: Bool = false
    var isUpdatingData: Bool = true
    var isActive: Bool = false
    
    //MARK: LifeCycle
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        isActive = true
        self.isUpdatingData = false
        
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        startAnimationWithDelay()
        
        if shouldShowFirstAlert {
            delay(1) { () -> () in
                if self.delegate == nil {
                    self.shouldShowFirstAlert = false
                    self.showPopup()
                }
            }
        }
    }
    
    override func didAppear() {
        super.didAppear()
        if shouldShowUpdateAlert {
            self.shouldShowUpdateAlert = false
            self.showUpdatePopup()
        }
    }
    
    override func didDeactivate() {
        isActive = false
        self.shouldStopAnimation = true
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //MARK: WCSessionDelegate
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
        if let size = message["dataSize"] as? Int {
            self.isUpdatingData = true
            
            connectionStatusLabel.setHidden(false)
            connectionStatusLabel.setText("Downloading...")
            
            if shouldStopAnimation {
                setuInitialAnimationPosition()
            }
            self.totalDataSize = size
            self.watchDatas.removeAll()
        }
    }
    
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
        print("WatchKit - userInfoTransfer : \(userInfoTransfer)")
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("WatchKit - didReceiveApplicationContext : \(applicationContext)")
        self.isUpdatingData = true
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
    
    func setImageTableDelegate(delegate: LoadAnimationInterfaceControllerDelegate?) {
        self.shouldShowUpdateAlert = true
        self.delegate = delegate
    }
   
    //MARK: Private Functions
    private func showPopup(){
        let action1 = WKAlertAction(title: "OK", style: .Default, handler:requestUpdate)
        let action2 = WKAlertAction(title: "Cancel", style: .Cancel, handler:requestUpdate)
        
        presentAlertControllerWithTitle("Warning!", message: "Open your App on iPhone to load new data!", preferredStyle: .ActionSheet, actions: [action1, action2])
    }
    
    private func showUpdatePopup(){
        
        let action1 = WKAlertAction(title: "YES", style: .Default, handler:requestUpdate)
        let action2 = WKAlertAction(title: "NO", style: .Destructive, handler:pushControlleImagesTable)
        let action3 = WKAlertAction(title: "Cancel", style: .Cancel, handler:pushControlleImagesTable)
        
        presentAlertControllerWithTitle("Update!", message: "Would you like to update your data?", preferredStyle: .ActionSheet, actions: [action1, action2,action3])
    }
    
    private func requestUpdate(){
        if !self.isUpdatingData {
            if self.session.reachable {
                let message = ["update":"yes"]
                sendMessageToiPhone(message)
            }
        }
        startAnimationWithDelay()
    }
    
    private func sendMessageToiPhone(message : [String: AnyObject]){
        self.session.sendMessage(message, replyHandler: { (response) -> Void in
            
            let status = response["replyHandler"] as! String
            if status == "Error" {
                self.showWarningPopup()
            }
            
            }, errorHandler: { (error) -> Void in
                self.showWarningPopup()
        })
        
        self.delay(5, closure: { () -> () in
            if !self.isUpdatingData {
                self.showTimeOutPopup()
            }
        })
    }
    
    private func showWarningPopup(){
        
        if isActive {
            let action1 = WKAlertAction(title: "Ok", style: .Default, handler:pushControlleImagesTable)
            let action2 = WKAlertAction(title: "Cancel", style: .Cancel, handler:pushControlleImagesTable)
            
            presentAlertControllerWithTitle("Warning!", message: "No new data!", preferredStyle: .ActionSheet, actions: [action1, action2])
        }
    }
    
    private func showTimeOutPopup(){
        
        if isActive {
            let action1 = WKAlertAction(title: "Ok", style: .Default, handler:requestUpdate)
            let action2 = WKAlertAction(title: "Cancel", style: .Cancel, handler:requestUpdate)
            
            presentAlertControllerWithTitle("Time Out!", message: "Connection time out! Please try again!", preferredStyle: .ActionSheet, actions: [action1, action2])
        }
    }
    
    private func pushControlleImagesTable(){
        isActive = false
        self.pushControllerWithName("ImagesTable", context: self)
    }
    
    private func setuInitialAnimationPosition(){
        self.mainGroup.stopAnimating()
        
        self.circleGroupRed.setVerticalAlignment(.Top)
        self.circleGroupBlue.setVerticalAlignment(.Top)
        self.circleGroupGreen.setVerticalAlignment(.Top)
        
        delay(0.1) {
            self.circleGroupRed.setHorizontalAlignment(.Left)
        }
        delay(0.2) {
            self.circleGroupBlue.setHorizontalAlignment(.Left)
        }
        delay(0.3) {
            self.circleGroupGreen.setHorizontalAlignment(.Left)
        }
        delay(0.4) {
            self.mainGroup.startAnimatingWithImagesInRange(NSRange(location: 0, length: 11), duration: 1.3, repeatCount: Int.max)
        }
    }
    
    private func updateImages(watchData: WatchData){
        self.watchDatas.updateValue(watchData, forKey: watchData.imagePosition)
        if self.watchDatas.count == totalDataSize {
            self.shouldStopAnimation = true
            self.isUpdatingData = false
            
            if self.delegate == nil && isActive {
                connectionStatusLabel.setHidden(true)
                isActive = false
                self.pushControllerWithName("ImagesTable", context: self)
            } else {
                self.delegate?.updateData()
            }
        }
    }
    
    private func startAnimationWithDelay(){
        setuInitialAnimationPosition()
        delay(1) { () -> () in
            self.shouldStopAnimation = false
            self.startAnimation()
        }
    }
    
    private func startAnimation(){
    
        if !self.shouldStopAnimation {
            self.animation(0.2) { () -> Void in
                self.circleGroupBlue.setHidden(false)
                self.circleGroupRed.setHidden(false)
                self.circleGroupGreen.setHidden(false)
                self.circleGroupRed.setHorizontalAlignment(.Right)
            }
            delay(0.3) {
                self.animation(0.3) { () -> Void in
                    self.circleGroupRed.setVerticalAlignment(.Bottom)
                }
            }
            
            delay(0.5) {
                self.animation(0.3) { () -> Void in
                    self.circleGroupBlue.setHorizontalAlignment(.Right)
                }
            }
            
            delay(0.6) {
                self.animation(0.3) { () -> Void in
                    self.circleGroupRed.setHorizontalAlignment(.Left)
                }
            }
            
            delay(0.7) {
                self.animation(0.3) { () -> Void in
                    self.circleGroupBlue.setVerticalAlignment(.Bottom)
                }
            }
            
            delay(0.7) {
                self.animation(0.3) { () -> Void in
                    self.circleGroupGreen.setHorizontalAlignment(.Right)
                }
            }
            
            delay(0.8) {
                self.animation(0.3) { () -> Void in
                    self.circleGroupRed.setVerticalAlignment(.Top)
                }
            }
            
            delay(0.9) {
                self.animation(0.3) { () -> Void in
                    self.circleGroupBlue.setHorizontalAlignment(.Left)
                }
            }
            
            delay(1) {
                self.animation(0.3) { () -> Void in
                    self.circleGroupGreen.setVerticalAlignment(.Bottom)
                }
            }
            
            delay(1.1) {
                self.animation(0.3) { () -> Void in
                    self.circleGroupBlue.setVerticalAlignment(.Top)
                }
            }
            
            delay(1.2) {
                self.animation(0.3) { () -> Void in
                    self.circleGroupGreen.setHorizontalAlignment(.Left)
                }
            }
            
            delay(1.5) {
                self.animation(0.3) { () -> Void in
                    self.circleGroupGreen.setVerticalAlignment(.Top)
                    self.startAnimation()
                }
            }
        }
    }
    
    func animation(duration: NSTimeInterval, completion: ()-> Void) {
        if !self.shouldStopAnimation {
            self.animateWithDuration(duration) { () -> Void in
              completion()
            }
        }
    }
    
    func delay(delay: NSTimeInterval, closure:() -> ()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
        
    }
    
}