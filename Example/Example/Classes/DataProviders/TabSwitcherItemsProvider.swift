//
//  TabItemsProvider.swift
//  ColorMatchTabs
//
//  Created by Sergey Butenko on 9/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import ColorMatchTabs

class TabItemsProvider {
    
    static let items = {
        return [
            TabItem(
                title: "Products",
                tintColor: UIColor(red: 0.51, green: 0.72, blue: 0.25, alpha: 1.00),
                normalImage: UIImage(named: "products_normal")!,
                highlightedImage: UIImage(named: "products_highlighted")!
            ),
            TabItem(
                title: "Places",
                tintColor: UIColor(red: 0.15, green: 0.67, blue: 0.99, alpha: 1.00),
                normalImage: UIImage(named: "venues_normal")!,
                highlightedImage: UIImage(named: "venues_highlighted")!
            ),
            TabItem(
                title: "Reviews",
                tintColor: UIColor(red: 1.00, green: 0.61, blue: 0.16, alpha: 1.00),
                normalImage: UIImage(named: "reviews_normal")!,
                highlightedImage: UIImage(named: "reviews_highlighted")!
            ),
            TabItem(
                title: "Friends",
                tintColor: UIColor(red: 0.96, green: 0.61, blue: 0.58, alpha: 1.00),
                normalImage: UIImage(named: "users_normal")!,
                highlightedImage: UIImage(named: "users_highlighted")!
            )
        ]
    }()
    
}
