//
//  ImageFeedItemTableViewCell.swift
//  FlickrImageFilter

//  Created by WELLINGTON BARBOSA on 2/27/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import UIKit

class ImageFeedItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: DownloadImageView!

    @IBOutlet weak var itemTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
