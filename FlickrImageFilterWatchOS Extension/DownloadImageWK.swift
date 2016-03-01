//
//  DownloadImageWK.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 3/1/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import WatchKit

class DownloadImageWK: NSObject  {
     
    @IBOutlet var imageViewInterface: WKInterfaceImage!
    
    let queue = NSOperationQueue()
    let mainQueue = NSOperationQueue.mainQueue()
    
    func setUrl(url: String){
        setUrl(url, cache: false)
    }
    
    func setUrl(url: String, cache: Bool){
        queue.cancelAllOperations()
        queue.addOperationWithBlock({self.downlaodImg(url, cache: cache)})
    }
    
    func downlaodImg(url: String, cache: Bool){
        var data: NSData!
        
        if(!cache){
            data = NSData(contentsOfURL: NSURL(string: url)!)!
        }else {
            var path = replace(url, _string: "/", _withString: "_")
            path = replace(path, _string: "\\", _withString: "_")
            path = replace(path, _string: ":", _withString: "_")
            path = NSHomeDirectory() + "/Documents/" + path
            
            let exists = NSFileManager.defaultManager().fileExistsAtPath(path)
            if(exists){
                data = NSData(contentsOfFile: path)
            }else{
                data = NSData(contentsOfURL: NSURL(string: url)!)!
                data.writeToFile(path, atomically: true)
            }
        }
        mainQueue.addOperationWithBlock({self.showImg(data)})
    }
    
    func showImg(data: NSData){
        if(data.length > 0){ 
            imageViewInterface.setImage(UIImage(data: data))
        }
    }
    
    func replace(aString: String, _string: String, _withString: String) -> String {
        return aString.stringByReplacingOccurrencesOfString(_string, withString: _withString)
    }

}