//
//  DownloadImageView.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 02/27/16.
//  Copyright © 2015 WELLINGTON BARBOSA. All rights reserved.
//

import UIKit

class DownloadImageView: UIImageView {
    
    var progress: UIActivityIndicatorView!
    let queue = NSOperationQueue()
    let mainQueue = NSOperationQueue.mainQueue()
    
    required init(coder aDecoder: NSCoder){ 
        super.init(coder: aDecoder)!
        createProgress()
    }
    
    func createProgress(){
        progress = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        addSubview(progress)
    }
    
    override func layoutSubviews() {
        progress.center = convertPoint(self.center, fromView: self.superview)
    }
    
    func setUrl(url: String){
        setUrl(url, cache: false)
    }
    
    func cacheFilteredImg(url: String){
        
        queue.cancelAllOperations()
        var path = replace(url, _string: "/", _withString: "_")
        path = replace(path, _string: "\\", _withString: "_")
        path = replace(path, _string: ":", _withString: "_")
        path = replace(path, _string: ".jpg", _withString: "_Filtered.jpg")
        path = NSHomeDirectory() + "/Documents/" + path
         
        queue.addOperationWithBlock(
            {
                let imageData: NSData = UIImagePNGRepresentation(self.image!)!
                imageData.writeToFile(path, atomically: true)
            })
    }
    
    func setUrl(url: String, cache: Bool){
        self.image = nil
        queue.cancelAllOperations()
        progress.startAnimating()
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
    
    func downlaodCachedFilteredImg(url: String){
        var data: NSData!
        
        var path = replace(url, _string: "/", _withString: "_")
        path = replace(path, _string: "\\", _withString: "_")
        path = replace(path, _string: ":", _withString: "_")
        path = replace(path, _string: ".jpg", _withString: "_Filtered.jpg")
        path = NSHomeDirectory() + "/Documents/" + path
        
        data = NSData(contentsOfFile: path)
        
        mainQueue.addOperationWithBlock({self.showImg(data)})
    }
    
    func showImg(data: NSData){
        if(data.length > 0){
            self.image = UIImage(data: data)
        }
        progress.stopAnimating()
    }
    
    func replace(aString: String, _string: String, _withString: String) -> String {
        return aString.stringByReplacingOccurrencesOfString(_string, withString: _withString)
    }
    
}