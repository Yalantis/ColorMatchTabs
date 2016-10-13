//
//  ControllersProvider.swift
//  ColorMatchTabs
//
//  Created by anna on 6/15/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import ColorMatchTabs

class StubContentViewControllersProvider {
    
    static let viewControllers: [UIViewController] = {
        let productsViewController = StubContentViewController()
        productsViewController.type = .products
        
        let venuesViewController = StubContentViewController()
        venuesViewController.type = .venues
        
        let reviewsViewController = StubContentViewController()
        reviewsViewController.type = .reviews
        
        let usersViewController = StubContentViewController()
        usersViewController.type = .users
        
        return [productsViewController, venuesViewController, reviewsViewController, usersViewController]
    }()

}
