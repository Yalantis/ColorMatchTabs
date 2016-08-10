//
//  MenuView.swift
//  ColorMatchTabs
//
//  Created by Serhii Butenko on 27/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class MenuView: UIView {
    
    internal(set) var navigationBar: UIView!
    internal(set) var tabs: ColorTabs!
    internal(set) var scrollMenu: ScrollMenu!
    internal(set) var circleMenuButton: UIButton!
    private var shadowView: VerticalGradientView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        layoutIfNeeded()
    }
    
    func setCircleMenuButtonHidden(hidden: Bool) {
        circleMenuButton.hidden = hidden
        shadowView.hidden = hidden
    }
    
}

// Init
private extension MenuView {
    
    func commonInit() {
        backgroundColor = .whiteColor()
        createSubviews()
        
        layoutNavigationBar()
        layoutTabs()
        layoutScrollMenu()
        layoutShadowView()
        layoutCircleMenu()
    }
    
    func createSubviews() {
        scrollMenu = ScrollMenu()
        addSubview(scrollMenu)
        
        navigationBar = ExtendedNavigationBar()
        navigationBar.backgroundColor = .whiteColor()
        addSubview(navigationBar)
        
        tabs = ColorTabs()
        tabs.userInteractionEnabled = true
        navigationBar.addSubview(tabs)
        
        shadowView = VerticalGradientView()
        shadowView.hidden = true
        shadowView.topColor = UIColor(white: 1, alpha: 0)
        shadowView.bottomColor = UIColor(white: 1, alpha: 1)
        addSubview(shadowView)
        
        circleMenuButton = UIButton()
        circleMenuButton.hidden = true
        circleMenuButton.setImage(UIImage(namedInCurrentBundle: "circle_menu"), forState: .Normal)
        circleMenuButton.adjustsImageWhenHighlighted = false
        addSubview(circleMenuButton)
    }
    
}

// Layout
private extension MenuView {
    
    func layoutNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        navigationBar.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        navigationBar.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        navigationBar.heightAnchor.constraintEqualToConstant(50).active = true
    }
    
    func layoutTabs() {
        tabs.translatesAutoresizingMaskIntoConstraints = false
        tabs.leadingAnchor.constraintEqualToAnchor(navigationBar.leadingAnchor).active = true
        tabs.topAnchor.constraintEqualToAnchor(navigationBar.topAnchor).active = true
        tabs.trailingAnchor.constraintEqualToAnchor(navigationBar.trailingAnchor).active = true
        tabs.heightAnchor.constraintEqualToConstant(44).active = true
    }
    
    func layoutScrollMenu() {
        scrollMenu.translatesAutoresizingMaskIntoConstraints = false
        scrollMenu.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        scrollMenu.topAnchor.constraintEqualToAnchor(navigationBar.bottomAnchor).active = true
        scrollMenu.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        scrollMenu.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
    }
    
    func layoutShadowView() {
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        shadowView.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        shadowView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        shadowView.heightAnchor.constraintEqualToConstant(80).active = true
    }
    
    func layoutCircleMenu() {
        circleMenuButton.translatesAutoresizingMaskIntoConstraints = false
        circleMenuButton.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: PlusButtonButtonOffset).active = true
        circleMenuButton.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    }
    
}