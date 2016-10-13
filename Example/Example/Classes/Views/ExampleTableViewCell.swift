//
//  ExampleTableViewCell.swift
//  ColorMatchTabs
//
//  Created by anna on 6/15/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ExampleTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var contentImageView: UIImageView!

    func apply(_ image: UIImage) {
        contentImageView.image = image
    }
    
}
