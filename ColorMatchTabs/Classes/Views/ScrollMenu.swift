//
//  ScrollMenu.swift
//  ColorMatchTabs
//
//  Created by anna on 6/15/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

@objc public protocol ScrollMenuDelegate: UIScrollViewDelegate {
    
    optional func scrollMenu(scrollMenu: ScrollMenu, didSelectedItemAt index: Int)
    
}

@objc public protocol ScrollMenuDataSource: class {
    
    func numberOfItemsInScrollMenu(scrollMenu: ScrollMenu) -> Int
    func scrollMenu(scrollMenu: ScrollMenu, viewControllerAtIndex index: Int) -> UIViewController
    
}

public class ScrollMenu: UIScrollView {
    
    @IBOutlet public weak var menuDelegate: ScrollMenuDelegate?
    @IBOutlet public weak var dataSource: ScrollMenuDataSource?
    
    public var indexOfVisibleItem: Int {
        if bounds.width > 0 {
            return Int(round(contentOffset.x / bounds.width))
        }
        return 0
    }
    
    private var previousIndex = 0
    private var destinationIndex: Int?
    private var manualSelection = false
    
    private var viewControllers: [UIViewController] = [] {
        didSet {
            layoutContent()
        }
    }
    
    override public var contentOffset: CGPoint {
        didSet {
            if let destinationIndex = destinationIndex where manualSelection && destinationIndex != indexOfVisibleItem {
                return
            }
            if !manualSelection {
                showAllContent()
            }
            manualSelection = false
            
            if indexOfVisibleItem != previousIndex {
                previousIndex = indexOfVisibleItem
                destinationIndex = nil
                
                menuDelegate?.scrollMenu?(self, didSelectedItemAt: indexOfVisibleItem)
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
        pagingEnabled = true
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layoutContent()
    }
    
    public func selectItem(atIndex index: Int) {
        guard indexOfVisibleItem != index else {
            return
        }
        
        manualSelection = true
        destinationIndex = index
        
        let first = min(index, indexOfVisibleItem) + 1
        let last = max(index, indexOfVisibleItem)
        hideContent(forRange: first..<last)
        updateContentOffset(withIndex: index)
    }
 
    public func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        viewControllers = []
        for index in 0..<dataSource.numberOfItemsInScrollMenu(self) {
            let viewController = dataSource.scrollMenu(self, viewControllerAtIndex: index)
            viewControllers.append(viewController)
            addSubview(viewController.view)
        }
        
        layoutContent()
    }
    
    
    public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateContentOffset(withIndex: indexOfVisibleItem)
    }
    
}

private extension ScrollMenu {
    
    func layoutContent() {
        contentSize = CGSize(width: bounds.width * CGFloat(viewControllers.count), height: bounds.height)
        
        for (index, viewController) in viewControllers.enumerate() {
            viewController.view.frame = CGRect(
                x: bounds.width * CGFloat(index),
                y: 0,
                width: bounds.width,
                height: bounds.height 
            )
        }
    }
    
    private func updateContentOffset(withIndex index: Int) {
        if viewControllers.count > index {
            let width = viewControllers[index].view.bounds.width
            let contentOffsetX = width * CGFloat(index)
            setContentOffset(CGPoint(x: contentOffsetX, y: contentOffset.y), animated: true)
        }
    }
    
    func hideContent(forRange range: Range<Int>) {
        viewControllers.enumerate().forEach { index, viewController in
            viewController.view.hidden = range.contains(index)
        }
    }

    func showAllContent() {
         viewControllers.forEach { viewController in
            viewController.view.hidden = false
        }
    }
    
}