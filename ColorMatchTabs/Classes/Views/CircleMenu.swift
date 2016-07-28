//
//  ColorMatchTabs.swift
//  ColorMatchTabs
//
//  Created by Sergey Butenko on 9/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

@objc public protocol CircleMenuDelegate: class {
    
    optional func circleMenuWillDisplayItems(circleMenu: CircleMenu)
    optional func circleMenuWillHideItems(circleMenu: CircleMenu)
    
    optional func circleMenu(circleMenu: CircleMenu, didSelectItemAt index: Int)
    
}

public protocol CircleMenuDataSource: class {
    
    func numberOfItems(inMenu circleMenu: CircleMenu) -> Int
    func circleMenu(circleMenu: CircleMenu, tintColorAt index: Int) -> UIColor
    
}

/// A menu with items spreaded by a circle around the button.
public class CircleMenu: UIControl {
    
    /// Delegate.
    @IBInspectable public weak var delegate: CircleMenuDelegate?
    
    /// Delegate.
    @IBInspectable public weak var dataSource: CircleMenuDataSource?
    
    /// Animation delay.
    @IBInspectable public var animationDelay: NSTimeInterval = 0
    
    /// Animation duration.
    @IBInspectable public var animationDuration: NSTimeInterval = 0.5
    
    // Radius of spreading the elements.
    @IBInspectable public var itemsSpacing: CGFloat = 130
    
    /// Item dimension.
    @IBInspectable public var itemDimension: CGFloat = 50
    
    /// Image for a button to open/close menu.
    @IBInspectable public var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    private var visible = false
    private var buttons: [UIButton] = []
    private var imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override public var frame: CGRect {
        didSet {
            imageView.frame = bounds
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            imageView.frame = bounds
        }
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        buttons.forEach { superview?.addSubview($0) }
    }
 
}

public extension CircleMenu {
    
    func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        removeOldButtons()
        
        for index in 0..<dataSource.numberOfItems(inMenu: self) {
            let button = UIButton(frame: CGRect.zero)
            
            button.addTarget(self, action: #selector(selectItem(_:)), forControlEvents: .TouchUpInside)
            button.tag = index
            button.layoutIfNeeded()
            button.backgroundColor = dataSource.circleMenu(self, tintColorAt: index)
            button.layer.cornerRadius = itemDimension / 2
            button.layer.masksToBounds = true
            
            buttons.append(button)
        }
    }
    
    /**
     - parameter index: Index of item
     
     - returns: CGPoint with center of item at index
     */
    func centerOfItem(atIndex index: Int) -> CGPoint {
        let count = dataSource?.numberOfItems(inMenu: self) ?? 0
        assert(index >= 0)
        assert(index < count)
        
        let deltaAngle = CGFloat(M_PI / Double(Double(count)))
        let angle = deltaAngle * CGFloat(Double(index) + 0.5) - CGFloat(M_PI)
        
        let x = itemsSpacing * cos(angle) + bounds.size.width / 2
        let y = itemsSpacing * sin(angle) + bounds.size.height / 2
        let point = CGPoint(x: x, y: y)
        let convertedPoint = convertPoint(point, toView: superview)
        
        return convertedPoint
    }
    
    func selectItem(atIndex atIndex: Int) {
        let count = dataSource?.numberOfItems(inMenu: self) ?? 0
        guard atIndex < count else {
            return
        }
        
        if visible {
            delegate?.circleMenu?(self, didSelectItemAt: atIndex)
            hideItems()
        }
    }
    
    @objc func triggerMenu(sender: AnyObject? = nil) {
        assert(superview != nil, "You must add the menu to superview before perfoming any actions with it")
        
        visible = !visible
        if visible {
            showItems()
        } else {
            hideItems()
        }
        setCloseButtonHidden(!visible)
    }
    
    @objc func selectItem(sender: UIButton) {
        hideItems()
        delegate?.circleMenu?(self, didSelectItemAt: sender.tag)
    }
}

// setup
private extension CircleMenu {
    
    func commonInit() {
        addSubview(imageView)
        addTarget(self, action: #selector(triggerMenu), forControlEvents: .TouchUpInside)
    }
        
    func removeOldButtons() {
        self.buttons.forEach {
            $0.removeFromSuperview()
        }
        buttons = []
    }
}

// animations
extension CircleMenu {
    
    var sourceFrame: CGRect {
        let origin = CGPoint(x: center.x - itemDimension / 2, y: center.y - itemDimension / 2)
        let size = CGSize(width: itemDimension, height: itemDimension)
        return CGRect(origin: origin, size: size)
    }
    
    func showItems() {
        guard let superview = superview else {
            fatalError("You must add the menu to superview before perfoming any actions with it")
        }
        
        visible = true
        delegate?.circleMenuWillDisplayItems?(self)
        
        for (index, button) in buttons.enumerate() {
            button.frame = sourceFrame
            performAnimated ({
                button.hidden = false
                button.frame = self.targetFrameForItem(at: index)
            })
        }
        superview.bringSubviewToFront(self)
    }
    
    func hideItems() {
        assert(superview != nil, "You must add the menu to superview before perfoming any actions with it")
        
        delegate?.circleMenuWillHideItems?(self)
        
        setCloseButtonHidden(true)
        performAnimated({
            for button in self.buttons {
                button.frame = self.sourceFrame
                button.hidden = true
            }
        })
        visible = false
    }
    
    func setCloseButtonHidden(hidden: Bool) {
        performAnimated({
            self.transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(CGFloat(M_PI) * 0.75)
        })
    }
    
    func performAnimated(block: () -> Void, completion: (Bool -> Void)? = nil) {
        UIView.animateWithDuration(
            animationDuration,
            delay: animationDelay,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 3,
            options: [],
            animations: block,
            completion: completion
        )
    }
    
    func targetFrameForItem(at index: Int) -> CGRect {
        let centerPoint = centerOfItem(atIndex: index)
        let itemOrigin = CGPoint(x: centerPoint.x - itemDimension / 2, y: centerPoint.y - itemDimension / 2)
        let itemSize = CGSize(width: itemDimension, height: itemDimension)
        let targetFrame = CGRect(origin: itemOrigin, size: itemSize)
        
        return targetFrame
    }
    
}