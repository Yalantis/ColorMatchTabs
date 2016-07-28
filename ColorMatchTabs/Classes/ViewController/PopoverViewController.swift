//
//  PopoverViewController.swift
//  ColorMatchTabs
//
//  Created by Serhii Butenko on 27/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let ContentPadding: CGFloat = 20

@objc public protocol PopoverViewControllerDataSource: class {
    
    func numberOfItems(inPopoverViewController popoverViewController: PopoverViewController) -> Int
    
    func popoverViewController(popoverViewController: PopoverViewController, iconAt index: Int) -> UIImage
    func popoverViewController(popoverViewController: PopoverViewController, hightlightedIconAt index: Int) -> UIImage
    
}

public class PopoverViewController: UIViewController {
    
    public weak var dataSource: PopoverViewControllerDataSource?
    public let contentView = UIView()
    
    var highlightedItemIndex: Int!
    let menu: CircleMenu = CircleMenu()
    
    private var icons: [UIImageView] = []
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContentView()
        setupMenu()
        view.layoutIfNeeded()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        menu.triggerMenu()
    }
    
    public func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        icons.forEach { $0.removeFromSuperview() }
        icons = []
        
        for index in 0..<dataSource.numberOfItems(inPopoverViewController: self) {
            let size = CGSize(width: menu.bounds.size.width / 2, height: menu.bounds.size.height / 2)
            let origin = menu.centerOfItem(atIndex: index)
            let iconImageView = UIImageView(frame: CGRect(origin: origin, size: size))
            
            iconImageView.image = dataSource.popoverViewController(self, hightlightedIconAt: index)
            iconImageView.contentMode = .Center
            iconImageView.hidden = true
            
            view.addSubview(iconImageView)
            icons.append(iconImageView)
        }
        moveIconsToDefaultPositions()
    }
    
}

// setup
private extension PopoverViewController {
    
    func setupContentView() {
        view.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: ContentPadding).active = true
        contentView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -ContentPadding).active = true
        
        topConstraint = contentView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: view.bounds.height)
        bottomConstraint = contentView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: view.bounds.height)
        topConstraint.active = true
        bottomConstraint.active = true
    }
    
    func setupMenu() {
        guard let image = UIImage(namedInCurrentBundle: "circle_menu") else {
            return
        }
        
        menu.image = image
        menu.delegate = self
        view.addSubview(menu)
        menu.addTarget(self, action: #selector(hidePopover(_:)), forControlEvents: .TouchUpInside)
        
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: PlusButtonButtonOffset).active = true
        menu.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        menu.widthAnchor.constraintEqualToConstant(image.size.width).active = true
        menu.heightAnchor.constraintEqualToConstant(image.size.height).active = true
    }
    
}

// actions
private extension PopoverViewController {
    
    @objc func hidePopover(sender: AnyObject?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// animation
private extension PopoverViewController {
    
    func moveIconsToDefaultPositions() {
        for (index, iconImageView) in icons.enumerate() {
            UIView.animateWithDuration(
                AnimationDuration,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 3,
                options: [],
                animations: {
                    iconImageView.center = CGPoint(
                        x: iconImageView.center.x,
                        y: iconImageView.center.y - self.view.frame.height / 2
                    )
                    
                    let shouldHighlight = index == self.highlightedItemIndex
                    if shouldHighlight {
                        iconImageView.image = self.dataSource?.popoverViewController(self, hightlightedIconAt: index)
                    } else {
                        iconImageView.image = self.dataSource?.popoverViewController(self, iconAt: index)
                    }
                },
                completion: nil
            )
        }
    }
    
    func moveIconsToCircle() {
        for (index, iconImageView) in icons.enumerate() {
            iconImageView.hidden = false
            
            UIView.animateWithDuration(
                AnimationDuration,
                delay: 0,
                usingSpringWithDamping: 0.95,
                initialSpringVelocity: 3,
                options: [],
                animations: {
                    iconImageView.center = self.menu.centerOfItem(atIndex: index)
                    iconImageView.image = self.dataSource?.popoverViewController(self, hightlightedIconAt: index)
                },
                completion: nil
            )
        }
    }
    
    private func showContentView() {
        let count = dataSource!.numberOfItems(inPopoverViewController: self)
        let center = menu.centerOfItem(atIndex: count / 2)
        let bottomOffset = view.bounds.height - center.y + menu.itemDimension / 2 + ContentPadding
        
        contentView.layer.addAnimation(CAAnimation.opacityAnimation(withDuration: AnimationDuration, initialValue: 0, finalValue: 1), forKey: nil)
        contentView.alpha = 1
        
        topConstraint.constant = ContentPadding
        bottomConstraint.constant = -bottomOffset
        UIView.animateWithDuration(
            AnimationDuration,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 3,
            options: [],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    private func hideContentMenu() {
        contentView.layer.addAnimation(CAAnimation.opacityAnimation(withDuration: AnimationDuration, initialValue: 1, finalValue: 0), forKey: nil)
        contentView.alpha = 0
        
        topConstraint.constant += view.bounds.height
        bottomConstraint.constant += view.bounds.height
        
        UIView.animateWithDuration(
            AnimationDuration,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
}

extension PopoverViewController: CircleMenuDelegate {
    
    public func circleMenuWillDisplayItems(circleMenu: CircleMenu) {
        moveIconsToCircle()
        showContentView()
    }

    public func circleMenuWillHideItems(circleMenu: CircleMenu) {
        moveIconsToDefaultPositions()
        hideContentMenu()
    }
    
}