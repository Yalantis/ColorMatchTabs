//
//  ColorTabs.swift
//  ColorMatchTabs
//
//  Created by Sergey Butenko on 13/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let HighlighterViewOffScreenOffset: CGFloat = 44

private let SwitchAnimationDuration: NSTimeInterval = 0.3
private let HighlighterAnimationDuration: NSTimeInterval = SwitchAnimationDuration / 2

@objc public protocol ColorTabsDataSource: class {
    
    func numberOfItems(inTabSwitcher tabSwitcher: ColorTabs) -> Int
    func tabSwitcher(tabSwitcher: ColorTabs, titleAt index: Int) -> String
    func tabSwitcher(tabSwitcher: ColorTabs, iconAt index: Int) -> UIImage
    func tabSwitcher(tabSwitcher: ColorTabs, hightlightedIconAt index: Int) -> UIImage
    func tabSwitcher(tabSwitcher: ColorTabs, tintColorAt index: Int) -> UIColor
    
}

public class ColorTabs: UIControl {
    
    public weak var dataSource: ColorTabsDataSource?
    
    /// Text color for titles.
    public var titleTextColor: UIColor = .whiteColor()
    
    /// Font for titles.
    public var titleFont: UIFont = .systemFontOfSize(14)
    
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private var labels: [UILabel] = []
    private(set) lazy var highlighterView: UIView = {
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: self.bounds.height))
        let highlighterView = UIView(frame: frame)
        highlighterView.layer.cornerRadius = self.bounds.height / 2
        self.addSubview(highlighterView)
        self.sendSubviewToBack(highlighterView)
        
        return highlighterView
    }()
    
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
            stackView.frame = bounds
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            stackView.frame = bounds
        }
    }

    public var selectedSegmentIndex: Int = 0 {
        didSet {
            if oldValue != selectedSegmentIndex {
                transition(from: oldValue, to: selectedSegmentIndex)
                sendActionsForControlEvents(.ValueChanged)
            }
        }
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window != nil {
            layoutIfNeeded()
            let countItems = dataSource?.numberOfItems(inTabSwitcher: self) ?? 0
            if countItems > selectedSegmentIndex {
                transition(from: selectedSegmentIndex, to: selectedSegmentIndex)
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        moveHighlighterView(toItemAt: selectedSegmentIndex)
    }
    
    public func centerOfItem(atIndex index: Int) -> CGPoint {
        return buttons[index].center
    }
    
    public func setIconsHidden(hidden: Bool) {
        buttons.forEach {
            $0.alpha = hidden ? 0 : 1
        }
    }
    
    public func setHighlighterHidden(hidden: Bool) {
        let sourceHeight = hidden ? bounds.height : 0
        let targetHeight = hidden ? 0 : bounds.height
        
        let animation: CAAnimation = {
            $0.fromValue = sourceHeight / 2
            $0.toValue = targetHeight / 2
            $0.duration = HighlighterAnimationDuration
            return $0
        }(CABasicAnimation(keyPath: "cornerRadius"))
        highlighterView.layer.addAnimation(animation, forKey: nil)
        highlighterView.layer.cornerRadius = targetHeight / 2
        
        UIView.animateWithDuration(HighlighterAnimationDuration) {
            self.highlighterView.frame.size.height = targetHeight
            self.highlighterView.alpha = hidden ? 0 : 1
            
            for label in self.labels  {
                label.alpha = hidden ? 0 : 1
            }
        }
    }
    
    public func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        buttons = []
        labels = []
        let count = dataSource.numberOfItems(inTabSwitcher: self)
        for index in 0..<count {
            let button = createButton(forIndex: index, withDataSource: dataSource)
            buttons.append(button)
            stackView.addArrangedSubview(button)
            
            let label = createLabel(forIndex: index, withDataSource: dataSource)
            labels.append(label)
            stackView.addArrangedSubview(label)
        }
    }
    
}

/// Setup
private extension ColorTabs {
    
    private func commonInit() {
        addSubview(stackView)
        stackView.distribution = .FillEqually
    }
    
    func createButton(forIndex index: Int, withDataSource dataSource: ColorTabsDataSource) -> UIButton {
        let button = UIButton()
        
        button.setImage(dataSource.tabSwitcher(self, iconAt: index), forState: .Normal)
        button.setImage(dataSource.tabSwitcher(self, hightlightedIconAt: index), forState: .Selected)
        button.addTarget(self, action: #selector(selectButton(_:)), forControlEvents: .TouchUpInside)
        
        return button
    }
    
    func createLabel(forIndex index: Int, withDataSource dataSource: ColorTabsDataSource) -> UILabel {
        let label = UILabel()
        
        label.hidden = true
        label.textAlignment = .Left
        label.text = dataSource.tabSwitcher(self, titleAt: index)
        label.textColor = titleTextColor
        label.adjustsFontSizeToFitWidth = true
        label.font = titleFont
        
        return label
    }
    
}

private extension ColorTabs {

    @objc func selectButton(sender: UIButton) {
        if let index = buttons.indexOf(sender) {
            selectedSegmentIndex = index
        }
    }
    
    func transition(from fromIndex: Int, to toIndex: Int) {
        guard let fromLabel = labels[safe: fromIndex],
            fromIcon = buttons[safe: fromIndex],
            toLabel = labels[safe: toIndex],
            toIcon = buttons[safe: toIndex] else {
                return
        }
        
        let animation = {
            fromLabel.hidden = true
            fromLabel.alpha = 0
            fromIcon.selected = false
            
            toLabel.hidden = false
            toLabel.alpha = 1
            toIcon.selected = true
            
            self.stackView.layoutIfNeeded()
            self.layoutIfNeeded()
            self.moveHighlighterView(toItemAt: toIndex)
        }
        
        UIView.animateWithDuration(
            SwitchAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 3,
            options: [],
            animations: animation,
            completion: nil
        )
    }
    
    func moveHighlighterView(toItemAt toIndex: Int) {
        guard let countItems = dataSource?.numberOfItems(inTabSwitcher: self) where countItems > toIndex else {
            return
        }
        
        let toLabel = labels[toIndex]
        let toIcon = buttons[toIndex]
        
        // offset for first item
        let point = convertPoint(toIcon.frame.origin, toView: self)
        let offsetForFirstItem: CGFloat = toIndex == 0 ? -HighlighterViewOffScreenOffset : 0
        highlighterView.frame.origin.x = point.x + offsetForFirstItem
        
        // offset for last item
        let offsetForLastItem: CGFloat = toIndex == countItems - 1 ? HighlighterViewOffScreenOffset : 0
        highlighterView.frame.size.width = toLabel.bounds.width + (toLabel.frame.origin.x - toIcon.frame.origin.x) + 10 - offsetForFirstItem + offsetForLastItem
        
        highlighterView.backgroundColor = dataSource!.tabSwitcher(self, tintColorAt: toIndex)
    }
    
}