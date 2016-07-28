//
//  ExamplePopoverViewController.swift
//  ColorMatchTabs
//
//  Created by Serhii Butenko on 27/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import ColorMatchTabs

class ExamplePopoverViewController: PopoverViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContentView()
    }
    
    private func setupContentView() {
        let imageView = UIImageView(image: UIImage(named: "popover_placeholder"))
        imageView.contentMode = .ScaleAspectFit
        contentView.addSubview(imageView)
        
        let padding: CGFloat = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: padding).active = true
        imageView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -padding).active = true
        imageView.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor).active = true
        imageView.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
    }
}