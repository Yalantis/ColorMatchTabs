//
//  ExtendedNavigationBar.swift
//  ColorMatchTabs
//
//  Created by Serhii Butenko on 27/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

final class ExtendedNavigationBar: UIView {
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        layer.shadowOffset = CGSize(width: 0, height: 1 / UIScreen.mainScreen().scale)
        layer.shadowRadius = 0
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.25
    }
    
}