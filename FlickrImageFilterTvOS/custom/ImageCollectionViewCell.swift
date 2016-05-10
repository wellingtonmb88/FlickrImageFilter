//
//  ImageCollectionViewCell.swift
//  FirstTV
//
//  Created by Mike Spears on 2016-01-11.
//  Copyright © 2016 YourOganisation. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: DownloadImageView!
    @IBOutlet weak var title: UILabel!
    
    weak var dataTask: NSURLSessionDataTask?
    
    override func prepareForReuse() {
        super.prepareForReuse()

        title.alpha = 0.0
        imageView.image = nil
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        title.alpha = 0.0
    }
    
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

        coordinator.addCoordinatedAnimations({
            if self.focused {
                self.title.alpha = 1.0
            }
            else {
                self.title.alpha = 0.0
            }
            }, completion: nil)
    }
}
    

