//
//  FilterUtils.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 2/27/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit

struct FilterUtils {
    
    
    static func generateIconForFilterButton(view: FilterMainViewController, type: Filter.FilterType, button: UIButton){
        let filter = Filter(img:UIImage(named: "sample"))
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            filter.setDefaultFilter(type)
            
            dispatch_async(dispatch_get_main_queue()) {
                let image = filter.getRGBImage().toUIImage()!
                button.setBackgroundImage(image, forState: .Normal)
                
                button.removeTarget(view, action: "onRed:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(view, action: "onGreen:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(view, action: "onBlue:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(view, action: "onContrast:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(view, action: "onBrightness:", forControlEvents: UIControlEvents.TouchUpInside)
                
                switch(type){
                case Filter.FilterType.RedOffset:
                    view.redButton.setBackgroundImage(image, forState: .Normal)
                    button.addTarget(view, action: "onRed:", forControlEvents: UIControlEvents.TouchUpInside)
                    break
                    
                case Filter.FilterType.GreenOffset:
                    view.greenButton.setBackgroundImage(image, forState: .Normal)
                    button.addTarget(view, action: "onGreen:", forControlEvents: UIControlEvents.TouchUpInside)
                    break
                    
                case Filter.FilterType.BlueOffset:
                    view.blueButton.setBackgroundImage(image, forState: .Normal)
                    button.addTarget(view, action: "onBlue:", forControlEvents: UIControlEvents.TouchUpInside)
                    break
                    
                case Filter.FilterType.Contrast:
                    view.contrastButton.setBackgroundImage(image, forState: .Normal)
                    button.addTarget(view, action: "onContrast:", forControlEvents: UIControlEvents.TouchUpInside)
                    break
                    
                case Filter.FilterType.Brightness:
                    view.brightnessButton.setBackgroundImage(image, forState: .Normal)
                    button.addTarget(view, action: "onBrightness:", forControlEvents: UIControlEvents.TouchUpInside)
                    break
                }
            }
        }
    }

    static func applyFilterInBackground(filter: Filter, type: Filter.FilterType, editValue: Int, completionHandler:() ->Void){
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            if(editValue > -1){
                switch(type){
                case Filter.FilterType.RedOffset:
                    filter.setRedOffset(editValue)
                    break
                    
                case Filter.FilterType.GreenOffset:
                    filter.setGreenOffset(editValue)
                    break
                    
                case Filter.FilterType.BlueOffset:
                    filter.setBlueOffset(editValue)
                    break
                    
                case Filter.FilterType.Contrast:
                    filter.setContrast(editValue)
                    break
                    
                case Filter.FilterType.Brightness:
                    filter.setBrightness(editValue)
                    break
                }
            } else {
                filter.setDefaultFilter(type)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler()
            }
        }
    }
    
}