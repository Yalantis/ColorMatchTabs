//
//  TabSwitcherMenuItem.swift
//  CircleMenu
//
//  Created by Sergey Butenko on 16/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

/**
 *  Describes an item to display in top switcher.
 */
public struct TabSwitcherMenuItem {
    
    public let title: String
    public let tintColor: UIColor
    public let normalImage: UIImage
    public let highlightedImage: UIImage
    
    public init(title: String, tintColor: UIColor, normalImage: UIImage, highlightedImage: UIImage) {
        self.title = title
        self.tintColor = tintColor
        self.normalImage = normalImage
        self.highlightedImage = highlightedImage
    }
    
}