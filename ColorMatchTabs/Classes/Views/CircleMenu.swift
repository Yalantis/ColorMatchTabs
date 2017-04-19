//
//  ColorMatchTabs.swift
//  ColorMatchTabs
//
//  Created by Sergey Butenko on 9/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

@objc public protocol CircleMenuDelegate: class {
    
    @objc optional func circleMenuWillDisplayItems(_ circleMenu: CircleMenu)
    @objc optional func circleMenuWillHideItems(_ circleMenu: CircleMenu)
    
    @objc optional func circleMenu(_ circleMenu: CircleMenu, didSelectItemAt index: Int)
    
}

public protocol CircleMenuDataSource: class {
    
    func numberOfItems(inMenu circleMenu: CircleMenu) -> Int
    func circleMenu(_ circleMenu: CircleMenu, tintColorAt index: Int) -> UIColor
    
}

/// A menu with items spreaded by a circle around the button.
open class CircleMenu: UIControl {
    
    /// Delegate.
    @IBInspectable open weak var delegate: CircleMenuDelegate?
    
    /// Delegate.
    @IBInspectable open weak var dataSource: CircleMenuDataSource?
    
    /// Animation delay.
    @IBInspectable open var animationDelay: TimeInterval = 0
    
    /// Animation duration.
    @IBInspectable open var animationDuration: TimeInterval = 0.5
    
    // Radius of spreading the elements.
    @IBInspectable open var itemsSpacing: CGFloat = 130
    
    /// Item dimension.
    @IBInspectable open var itemDimension: CGFloat = 50
    
    /// Image for a button to open/close menu.
    @IBInspectable open var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    fileprivate var visible = false
    fileprivate var buttons: [UIButton] = []
    fileprivate var imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override open var frame: CGRect {
        didSet {
            imageView.frame = bounds
        }
    }
    
    override open var bounds: CGRect {
        didSet {
            imageView.frame = bounds
        }
    }
    
    override open func didMoveToSuperview() {
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
            
            button.addTarget(self, action: #selector(selectItem(_:)), for: .touchUpInside)
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
        
        let deltaAngle = CGFloat(Double.pi / Double(Double(count)))
        let angle = deltaAngle * CGFloat(Double(index) + 0.5) - CGFloat(Double.pi)
        
        let x = itemsSpacing * cos(angle) + bounds.size.width / 2
        let y = itemsSpacing * sin(angle) + bounds.size.height / 2
        let point = CGPoint(x: x, y: y)
        let convertedPoint = convert(point, to: superview)
        
        return convertedPoint
    }
    
    func selectItem(atIndex: Int) {
        let count = dataSource?.numberOfItems(inMenu: self) ?? 0
        guard atIndex < count else {
            return
        }
        
        if visible {
            delegate?.circleMenu?(self, didSelectItemAt: atIndex)
            hideItems()
        }
    }
    
    @objc func triggerMenu(_ sender: AnyObject? = nil) {
        assert(superview != nil, "You must add the menu to superview before perfoming any actions with it")
        
        visible = !visible
        if visible {
            showItems()
        } else {
            hideItems()
        }
        setCloseButtonHidden(!visible)
    }
    
    @objc func selectItem(_ sender: UIButton) {
        hideItems()
        delegate?.circleMenu?(self, didSelectItemAt: sender.tag)
    }
}

// setup
private extension CircleMenu {
    
    func commonInit() {
        addSubview(imageView)
        addTarget(self, action: #selector(triggerMenu), for: .touchUpInside)
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
        
        for (index, button) in buttons.enumerated() {
            button.frame = sourceFrame
            performAnimated ({
                button.isHidden = false
                button.frame = self.targetFrameForItem(at: index)
            })
        }
        superview.bringSubview(toFront: self)
    }
    
    func hideItems() {
        assert(superview != nil, "You must add the menu to superview before perfoming any actions with it")
        
        delegate?.circleMenuWillHideItems?(self)
        
        setCloseButtonHidden(true)
        performAnimated({
            for button in self.buttons {
                button.frame = self.sourceFrame
                button.isHidden = true
            }
        })
        visible = false
    }
    
    func setCloseButtonHidden(_ hidden: Bool) {
        performAnimated({
            self.transform = hidden ? CGAffineTransform.identity : CGAffineTransform(rotationAngle: CGFloat(Double.pi) * 0.75)
        })
    }
    
    func performAnimated(_ block: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: animationDuration,
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
