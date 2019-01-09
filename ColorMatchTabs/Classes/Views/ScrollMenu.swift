//
//  ScrollMenu.swift
//  ColorMatchTabs
//
//  Created by anna on 6/15/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

@objc public protocol ScrollMenuDelegate: UIScrollViewDelegate {
    
    @objc
    optional func scrollMenu(_ scrollMenu: ScrollMenu, didSelectedItemAt index: Int)
    
}

@objc public protocol ScrollMenuDataSource: class {
    
    func numberOfItemsInScrollMenu(_ scrollMenu: ScrollMenu) -> Int
    func scrollMenu(_ scrollMenu: ScrollMenu, viewControllerAtIndex index: Int) -> UIViewController
    
}

open class ScrollMenu: UIScrollView {
    
    @IBOutlet open var menuDelegate: ScrollMenuDelegate?
    @IBOutlet open var dataSource: ScrollMenuDataSource?
    
    open var destinationIndex = 0
    
    private var indexOfVisibleItem: Int {
        if bounds.width > 0 {
            return min(Int(round(contentOffset.x / bounds.width)), viewControllers.count - 1)
        }
        return 0
    }
    private var previousIndex = 0
    private var manualSelection = false
    
    private var viewControllers: [UIViewController] = []
    
    override open var contentOffset: CGPoint {
        didSet {
            if manualSelection && destinationIndex != indexOfVisibleItem {
                return
            }
            if !manualSelection {
                showAllContent()
            }
            manualSelection = false
            
            if indexOfVisibleItem != previousIndex {
                previousIndex = indexOfVisibleItem
                if isDragging {
                    destinationIndex = indexOfVisibleItem
                }
                
                menuDelegate?.scrollMenu?(self, didSelectedItemAt: destinationIndex)
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    private func commonInit() {
        isPagingEnabled = true
        bounces = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        layoutContent()
    }
    
    open func selectItem(atIndex index: Int) {
        guard indexOfVisibleItem != index else {
            return
        }
        
        manualSelection = true
        destinationIndex = index
        
        let first = min(index, indexOfVisibleItem) + 1
        let last = max(index, indexOfVisibleItem)
        hideContent(forRange: first..<last)
        updateContentOffset(withIndex: index, animated: true)
    }
    
    open func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        var oldViewControllers = viewControllers
        let newViewControllers = (0..<dataSource.numberOfItemsInScrollMenu(self)).map { dataSource.scrollMenu(self, viewControllerAtIndex: $0) }
        newViewControllers.forEach { controller in
            let oldControllerIndex = oldViewControllers.firstIndex(of: controller)
            if let index = oldControllerIndex {
                oldViewControllers.remove(at: index)
            } else {
                addSubview(controller.view)
            }
        }
        oldViewControllers.forEach { $0.view.removeFromSuperview() }
        viewControllers = newViewControllers
        layoutContent()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateContentOffset(withIndex: destinationIndex, animated: false)
    }
    
}

private extension ScrollMenu {
    
    func layoutContent() {
        contentSize = CGSize(width: bounds.width * CGFloat(viewControllers.count), height: bounds.height)
        viewControllers.enumerated().forEach {
            $0.element.view.frame = CGRect(
                origin: CGPoint(x: bounds.width * CGFloat($0.offset), y: 0),
                size: bounds.size
            )
        }
    }
    
    func updateContentOffset(withIndex index: Int, animated: Bool) {
        if viewControllers.count > index {
            let width = viewControllers[index].view.bounds.width
            let contentOffsetX = width * CGFloat(index)
            setContentOffset(CGPoint(x: contentOffsetX, y: contentOffset.y), animated: animated)
        }
    }
    
    func hideContent(forRange range: Range<Int>) {
        viewControllers.enumerated().forEach { index, viewController in
            viewController.view.isHidden = range.contains(index)
        }
    }
    
    func showAllContent() {
        viewControllers.forEach { viewController in
            viewController.view.isHidden = false
        }
    }
    
}
