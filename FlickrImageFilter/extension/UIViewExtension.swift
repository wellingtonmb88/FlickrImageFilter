//
//  UIViewExtension.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 11/28/15.
//  Copyright © 2015 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    
    /**
    Fade in a view with a duration
    
    - parameter duration: custom animation duration
    */
    func fadeIn(alpha alpha:CGFloat, duration: NSTimeInterval, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, animations: {
            self.alpha = alpha
            },completion: completion)
    }
    
    /**
    Fade out a view with a duration
    
    - parameter duration: custom animation duration
    */
    func fadeOut(duration duration: NSTimeInterval, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, animations: {
            self.alpha = 0.0
            },completion: completion)
    }
}