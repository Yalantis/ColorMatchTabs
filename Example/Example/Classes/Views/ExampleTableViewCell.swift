//
//  ExampleTableViewCell.swift
//  ColorMatchTabs
//
//  Created by anna on 6/15/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ExampleTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var contentImageView: UIImageView!

    func apply(image: UIImage) {
        contentImageView.image = image
    }
    
}
