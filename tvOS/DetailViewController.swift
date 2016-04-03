//
//  DetailViewController.swift
//  FirstTV
//
//  Created by Mike Spears on 2016-01-11.
//  Copyright © 2016 YourOganisation. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var image: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var bottomRightButton: UIButton!
    
    @IBOutlet weak var topLeftButton: UIButton!
    
    var focusGuide: UIFocusGuide!
    var filter: Filter!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.image = self.image
        self.filter = Filter(img: self.image)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        focusGuide = UIFocusGuide()
        view.addLayoutGuide(focusGuide)
        
        // Anchor the top left of the focus guide.
        focusGuide.leftAnchor.constraintEqualToAnchor(bottomRightButton.leftAnchor).active = true
        focusGuide.topAnchor.constraintEqualToAnchor(topLeftButton.topAnchor).active = true
        
        // Anchor the width and height of the focus guide.
        focusGuide.widthAnchor.constraintEqualToAnchor(topLeftButton.widthAnchor).active = true
        focusGuide.heightAnchor.constraintEqualToAnchor(bottomRightButton.heightAnchor).active = true
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)

        guard let nextFocusedView = context.nextFocusedView else { return }
        
        switch nextFocusedView {
        case topLeftButton:
            focusGuide.preferredFocusedView = bottomRightButton
            
        case bottomRightButton:
            focusGuide.preferredFocusedView = topLeftButton
            
        default:
            focusGuide.preferredFocusedView = nil
        }
    }
    
    @IBAction func resetImage(sender: AnyObject) {
        self.imageView.image = self.image
        self.filter =  Filter(img: self.image)
    }
    
    @IBAction func setFilterGreen(sender: AnyObject) {
        Filter.applyFilterInBackground(self.filter, type: Filter.FilterType.GreenOffset, editValue: 5) {
            ()-> Void in
            self.imageView.image = self.filter.getRGBImage().toUIImage()
        }
    }
    
    @IBAction func setFilterBlue(sender: AnyObject) {
        Filter.applyFilterInBackground(self.filter, type: Filter.FilterType.BlueOffset, editValue: 5) {
            ()-> Void in
            self.imageView.image = self.filter.getRGBImage().toUIImage()
        }
    }
    
    @IBAction func setFilterRed(sender: AnyObject) {
        Filter.applyFilterInBackground(self.filter, type: Filter.FilterType.RedOffset, editValue: 5) {
            ()-> Void in
            self.imageView.image = self.filter.getRGBImage().toUIImage()
        }
    }
}
