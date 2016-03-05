//
//  InterfaceController.swift
//  FlickrImageFilterWatchOS Extension
//
//  Created by WELLINGTON BARBOSA on 2/29/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import WatchKit
import Foundation

protocol ImagesInterfaceControllerDelegate {
    func getWatchData() ->[Int: WatchData] 
    func setImageTableDelegate(delegate: LoadAnimationInterfaceControllerDelegate?)
}

class ImagesInterfaceController: WKInterfaceController, LoadAnimationInterfaceControllerDelegate {

    @IBOutlet var imagesTable: WKInterfaceTable!
    
    var watchDatas = [Int: WatchData]()
    var delegate: ImagesInterfaceControllerDelegate?
      
    //MARK: LifeCycle
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.delegate = context as? ImagesInterfaceControllerDelegate
        self.delegate?.setImageTableDelegate(self)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        updateTable()
    }
    
    override func didDeactivate() {
        self.delegate?.setImageTableDelegate(nil)
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //MARK: Private Functions
    private func updateTable(){
        
        watchDatas = (self.delegate?.getWatchData())!
        
        self.imagesTable.setNumberOfRows(watchDatas.count, withRowType: "ImageRow")
        
        for index in 0..<self.watchDatas.count {
            if let controller = imagesTable.rowControllerAtIndex(index) as? ImageViewInterfaceController {
                if let item = self.watchDatas[index] {
                    let image : UIImage = UIImage(data: item.imageData)!
                    controller.imageViewInterface.setImage(image)
                }
            }
        }
    }
    
    //MARK: TableRow Selection
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        
        let item = self.watchDatas[rowIndex]!
        let image : UIImage = UIImage(data: item.imageData)!
    
        let data = ["data": [["dataLabel": item.imageLabel], ["dataImage":image]]]
        
        self.presentControllerWithName("ImageDetails", context: data)
    }
    
    //MARK: LoadAnimationInterfaceControllerDelegate 
    func updateData() {
        updateTable()
    }
     
}





