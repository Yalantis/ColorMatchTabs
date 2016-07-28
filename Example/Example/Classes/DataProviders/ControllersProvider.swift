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
        productsViewController.type = .Products
        
        let venuesViewController = StubContentViewController()
        venuesViewController.type = .Venues
        
        let reviewsViewController = StubContentViewController()
        reviewsViewController.type = .Reviews
        
        let usersViewController = StubContentViewController()
        usersViewController.type = .Users
        
        return [productsViewController, venuesViewController, reviewsViewController, usersViewController]
    }()

}