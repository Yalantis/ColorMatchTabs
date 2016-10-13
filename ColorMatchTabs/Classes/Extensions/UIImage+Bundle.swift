//
//  UIImage+Bundle.swift
//  ColorMatchTabs
//
//  Created by Serhii Butenko on 27/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import class UIKit.UIImage

extension UIImage {
    
    convenience init?(namedInCurrentBundle: String) {
        self.init(named: namedInCurrentBundle, in: Bundle(for: ColorMatchTabsViewController.self), compatibleWith: nil)
    }
    
}
