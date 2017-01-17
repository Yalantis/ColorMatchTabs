//
//  ColorMatchTabsViewController.swift
//  ColorMatchTabs
//
//  Created by Serhii Butenko on 24/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

public protocol ColorMatchTabsViewControllerDataSource: class {
    
    func numberOfItems(inController controller: ColorMatchTabsViewController) -> Int
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, viewControllerAt index: Int) -> UIViewController
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, titleAt index: Int) -> String
    func tabsViewController(_ controller: ColorMatchTabsViewController, iconAt index: Int) -> UIImage
    func tabsViewController(_ controller: ColorMatchTabsViewController, hightlightedIconAt index: Int) -> UIImage
    func tabsViewController(_ controller: ColorMatchTabsViewController, tintColorAt index: Int) -> UIColor

}

open class ColorMatchTabsViewController: UITabBarController {
    
    @IBInspectable open weak var dataSource: ColorMatchTabsViewControllerDataSource? {
        didSet {
            _view.scrollMenu.dataSource = dataSource == nil ? nil : self
            _view.tabs.dataSource = dataSource == nil ? nil : self
        }
    }
    
    @IBInspectable open var scrollEnabled = true {
        didSet {
            updateScrollEnabled()
        }
    }
    
    open let titleLabel = UILabel()
    open var popoverViewController: PopoverViewController? {
        didSet {
            popoverViewController?.menu.dataSource = self
            popoverViewController?.dataSource = self
            
            let hidePopoverButton = popoverViewController == nil
            _view.setCircleMenuButtonHidden(hidePopoverButton)
        }
    }
    
    override open var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    open var selectedSegmentIndex: Int {
        return _view.tabs.selectedSegmentIndex
    }
    
    fileprivate var icons: [UIImageView] = []
    fileprivate let circleTransition = CircleTransition()
    
    var _view: MenuView! {
        return view as! MenuView
    }
    
    open override func loadView() {
        view = MenuView()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTabSwitcher()
        setupIcons()
        setupScrollMenu()
        setupCircleMenu()
        updateNavigationBar(forSelectedIndex: 0)
        updateScrollEnabled()
    }
    
    open func selectItem(at index: Int) {
        updateNavigationBar(forSelectedIndex: index)
        _view.tabs.selectedSegmentIndex = index
        _view.scrollMenu.selectItem(atIndex: index)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectItem(at: _view.tabs.selectedSegmentIndex)
        setDefaultPositions()
    }
    
    open func reloadData() {
        _view.tabs.reloadData()
        _view.scrollMenu.reloadData()
        popoverViewController?.menu.reloadData()
        
        updateNavigationBar(forSelectedIndex: 0)
        setupIcons()
    }
    
}

// setup
private extension ColorMatchTabsViewController {
    
    func setupIcons() {
        guard let dataSource = dataSource else {
            return
        }
        
        icons.forEach { $0.removeFromSuperview() }
        icons = []
        
        for index in 0..<dataSource.numberOfItems(inController: self) {
            let size = _view.circleMenuButton.bounds.size
            let frame = CGRect(origin: .zero, size: CGSize(width: size.width / 2, height: size.height / 2))
            let iconImageView = UIImageView(frame: frame)
            iconImageView.image = dataSource.tabsViewController(self, hightlightedIconAt: index)
            iconImageView.contentMode = .center
            iconImageView.isHidden = true
            
            view.addSubview(iconImageView)
            icons.append(iconImageView)
        }
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIImage(namedInCurrentBundle: "transparent_pixel")
        let pixelImage = UIImage(namedInCurrentBundle: "pixel")
        navigationController?.navigationBar.setBackgroundImage(pixelImage, for: .default)
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }
    
    func setupTabSwitcher() {
        _view.tabs.selectedSegmentIndex = 0
        _view.tabs.addTarget(self, action: #selector(changeContent(_:)), for: .valueChanged)
        _view.tabs.dataSource = self
    }
    
    func setupScrollMenu() {
        _view.scrollMenu.menuDelegate = self
    }
    
    func setupCircleMenu() {
        _view.circleMenuButton.addTarget(self, action: #selector(showPopover(_:)), for: .touchUpInside)
    }
    
    func updateNavigationBar(forSelectedIndex index: Int) {
        let color = dataSource?.tabsViewController(self, tintColorAt: index) ?? .white
        
        titleLabel.textColor = color
        _view.scrollMenu.backgroundColor = color.withAlphaComponent(0.2)
    }
    
    func updateScrollEnabled() {
        _view.scrollMenu.isScrollEnabled = scrollEnabled
    }
}

// animations
private extension ColorMatchTabsViewController {
    
    func setDefaultPositions() {
        _view.tabs.setHighlighterHidden(false)
        
        for (index, iconImageView) in icons.enumerated() {
            UIView.animate(
                withDuration: AnimationDuration,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 3,
                options: [],
                animations: {
                    let point = self._view.tabs.centerOfItem(atIndex: index)
                    iconImageView.center = self._view.tabs.convert(point, to: self.view)
                    
                    let image: UIImage?
                    if index == self._view.tabs.selectedSegmentIndex {
                        image = self.dataSource?.tabsViewController(self, hightlightedIconAt: index)
                    } else {
                        image = self.dataSource?.tabsViewController(self, iconAt: index)
                    }
                    iconImageView.image = image
                },
                completion: { _ in
                    self._view.tabs.setIconsHidden(false)
                    iconImageView.isHidden = true
                }
            )
        }
    }
    
    @objc func showPopover(_ sender: AnyObject?) {
        showDroppingItems()
        showPopover()
    }
    
    func showDroppingItems() {
        UIView.animate(withDuration: AnimationDuration, animations: {
            self._view.tabs.setHighlighterHidden(true)
        }) 
        
        for (index, iconImageView) in icons.enumerated() {
            iconImageView.center = _view.tabs.centerOfItem(atIndex: index)
            iconImageView.isHidden = false
            
            UIView.animate(
                withDuration: AnimationDuration,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 3,
                options: [],
                animations: {
                    iconImageView.image = self.dataSource?.tabsViewController(self, hightlightedIconAt: index)
                    iconImageView.center = CGPoint(
                        x: iconImageView.center.x,
                        y: iconImageView.center.y + self.view.frame.height / 2
                    )
                },
                completion: nil
            )
        }
        _view.tabs.setIconsHidden(true)
    }
    
    func showPopover() {
        guard let popoverViewController = popoverViewController else {
            return
        }
        
        popoverViewController.transitioningDelegate = self
        popoverViewController.highlightedItemIndex = _view.tabs.selectedSegmentIndex
        popoverViewController.view.backgroundColor = .white
        popoverViewController.reloadData()
        
        present(popoverViewController, animated: true, completion: nil)
    }
    
    @objc func changeContent(_ sender: ColorTabs) {
        updateNavigationBar(forSelectedIndex: sender.selectedSegmentIndex)
        if _view.scrollMenu.destinationIndex != sender.selectedSegmentIndex {
            _view.scrollMenu.selectItem(atIndex: sender.selectedSegmentIndex)
        }
    }
    
}

extension ColorMatchTabsViewController: ScrollMenuDelegate {
    
    public func scrollMenu(_ scrollMenu: ScrollMenu, didSelectedItemAt index: Int) {
        updateNavigationBar(forSelectedIndex: index)
        if _view.tabs.selectedSegmentIndex != index {
            _view.tabs.selectedSegmentIndex = index
        }
    }
    
}

extension ColorMatchTabsViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        circleTransition.mode = .show
        circleTransition.startPoint = _view.circleMenuButton.center
        
        return circleTransition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let dismissedViewController = dismissed as? PopoverViewController else {
            return nil
        }
        
        circleTransition.mode = .hide
        circleTransition.startPoint = dismissedViewController.menu.center
        
        return circleTransition
    }
    
}

// MARK: - Data sources

extension ColorMatchTabsViewController: ColorTabsDataSource {
    
    public func numberOfItems(inTabSwitcher tabSwitcher: ColorTabs) -> Int {
        return dataSource?.numberOfItems(inController: self) ?? 0
    }
    
    public func tabSwitcher(_ tabSwitcher: ColorTabs, titleAt index: Int) -> String {
        return dataSource!.tabsViewController(self, titleAt: index)
    }
    
    public func tabSwitcher(_ tabSwitcher: ColorTabs, iconAt index: Int) -> UIImage {
        return dataSource!.tabsViewController(self, iconAt: index)
    }
    
    public func tabSwitcher(_ tabSwitcher: ColorTabs, hightlightedIconAt index: Int) -> UIImage {
        return dataSource!.tabsViewController(self, hightlightedIconAt: index)
    }
    
    public func tabSwitcher(_ tabSwitcher: ColorTabs, tintColorAt index: Int) -> UIColor {
        return dataSource!.tabsViewController(self, tintColorAt: index)
    }
    
}

extension ColorMatchTabsViewController: ScrollMenuDataSource {
    
    public func numberOfItemsInScrollMenu(_ scrollMenu: ScrollMenu) -> Int {
        return dataSource?.numberOfItems(inController: self) ?? 0
    }
    
    public func scrollMenu(_ scrollMenu: ScrollMenu, viewControllerAtIndex index: Int) -> UIViewController {
        return dataSource!.tabsViewController(self, viewControllerAt: index)
    }
    
}

extension ColorMatchTabsViewController: CircleMenuDataSource {
    
    public func numberOfItems(inMenu circleMenu: CircleMenu) -> Int {
        return dataSource?.numberOfItems(inController: self) ?? 0
    }
    
    public func circleMenu(_ circleMenu: CircleMenu, tintColorAt index: Int) -> UIColor {
        return dataSource!.tabsViewController(self, tintColorAt: index)
    }
    
}

extension ColorMatchTabsViewController: PopoverViewControllerDataSource {
    
    public func numberOfItems(inPopoverViewController popoverViewController: PopoverViewController) -> Int {
        return dataSource?.numberOfItems(inController: self) ?? 0
    }
    
    public func popoverViewController(_ popoverViewController: PopoverViewController, iconAt index: Int) -> UIImage {
        return dataSource!.tabsViewController(self, iconAt: index)
    }
    
    public func popoverViewController(_ popoverViewController: PopoverViewController, hightlightedIconAt index: Int) -> UIImage {
        return dataSource!.tabsViewController(self, hightlightedIconAt: index)
    }
    
}
