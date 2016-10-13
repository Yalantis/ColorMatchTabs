//
//  PopoverViewController.swift
//  ColorMatchTabs
//
//  Created by Serhii Butenko on 27/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let ContentPadding: CGFloat = 20

@objc public protocol PopoverViewControllerDelegate: class {

    func popoverViewController(_ popoverViewController: PopoverViewController, didSelectItemAt index: Int)
    
}

@objc public protocol PopoverViewControllerDataSource: class {
    
    func numberOfItems(inPopoverViewController popoverViewController: PopoverViewController) -> Int
    
    func popoverViewController(_ popoverViewController: PopoverViewController, iconAt index: Int) -> UIImage
    func popoverViewController(_ popoverViewController: PopoverViewController, hightlightedIconAt index: Int) -> UIImage
    
}

open class PopoverViewController: UIViewController {
    
    open weak var dataSource: PopoverViewControllerDataSource?
    open weak var delegate: PopoverViewControllerDelegate?
    open let contentView = UIView()
    
    var highlightedItemIndex: Int!
    let menu: CircleMenu = CircleMenu()
    
    fileprivate var icons: [UIImageView] = []
    fileprivate var topConstraint: NSLayoutConstraint!
    fileprivate var bottomConstraint: NSLayoutConstraint!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContentView()
        setupMenu()
        view.layoutIfNeeded()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        menu.triggerMenu()
    }
    
    open func reloadData() {
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
            iconImageView.contentMode = .center
            iconImageView.isHidden = true
            
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
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ContentPadding).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ContentPadding).isActive = true
        
        topConstraint = contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height)
        bottomConstraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.bounds.height)
        topConstraint.isActive = true
        bottomConstraint.isActive = true
    }
    
    func setupMenu() {
        guard let image = UIImage(namedInCurrentBundle: "circle_menu") else {
            return
        }
        
        menu.image = image
        menu.delegate = self
        view.addSubview(menu)
        menu.addTarget(self, action: #selector(hidePopover(_:)), for: .touchUpInside)
        
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: PlusButtonButtonOffset).isActive = true
        menu.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        menu.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
        menu.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
    }
    
}

// actions
private extension PopoverViewController {
    
    @objc func hidePopover(_ sender: AnyObject? = nil) {
        dismiss(animated: true, completion: nil)
    }
    
}

// animation
private extension PopoverViewController {
    
    func moveIconsToDefaultPositions() {
        for (index, iconImageView) in icons.enumerated() {
            UIView.animate(
                withDuration: AnimationDuration,
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
        for (index, iconImageView) in icons.enumerated() {
            iconImageView.isHidden = false
            
            UIView.animate(
                withDuration: AnimationDuration,
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
    
    func showContentView() {
        let count = dataSource!.numberOfItems(inPopoverViewController: self)
        let center = menu.centerOfItem(atIndex: count / 2)
        let bottomOffset = view.bounds.height - center.y + menu.itemDimension / 2 + ContentPadding
        
        contentView.layer.add(CAAnimation.opacityAnimation(withDuration: AnimationDuration, initialValue: 0, finalValue: 1), forKey: nil)
        contentView.alpha = 1
        
        topConstraint.constant = ContentPadding
        bottomConstraint.constant = -bottomOffset
        UIView.animate(
            withDuration: AnimationDuration,
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
    
    func hideContentMenu() {
        contentView.layer.add(CAAnimation.opacityAnimation(withDuration: AnimationDuration, initialValue: 1, finalValue: 0), forKey: nil)
        contentView.alpha = 0
        
        topConstraint.constant += view.bounds.height
        bottomConstraint.constant += view.bounds.height
        
        UIView.animate(
            withDuration: AnimationDuration,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
}

extension PopoverViewController: CircleMenuDelegate {
    
    public func circleMenuWillDisplayItems(_ circleMenu: CircleMenu) {
        moveIconsToCircle()
        showContentView()
    }

    public func circleMenuWillHideItems(_ circleMenu: CircleMenu) {
        moveIconsToDefaultPositions()
        hideContentMenu()
    }
    
    public func circleMenu(_ circleMenu: CircleMenu, didSelectItemAt index: Int) {
        hidePopover()
        delegate?.popoverViewController(self, didSelectItemAt: index)
    }
    
}
