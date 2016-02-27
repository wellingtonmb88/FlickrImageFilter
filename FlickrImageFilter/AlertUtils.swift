//
//  AlertUtils.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 2/27/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit

struct AlertUtils {
    
    static func createAlertWithTextField(title: String, message: String, okActionHandler:(textFieldValue: String)->Void) -> UIViewController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
            if let textValue = alertController.textFields![0].text {
                okActionHandler(textFieldValue: textValue.stringByReplacingOccurrencesOfString(" ", withString: "",
                    options: NSStringCompareOptions.LiteralSearch, range: nil))
            }
        }
        
        alertController.addAction(defaultAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addTextFieldWithConfigurationHandler(nil)
        return alertController
    }
    
    static func createAlert(title: String, message: String) -> UIViewController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil) 
        alertController.addAction(defaultAction)
        return alertController
    }

    
}