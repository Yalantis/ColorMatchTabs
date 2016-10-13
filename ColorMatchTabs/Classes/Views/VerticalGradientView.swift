//
//  ExtendedNavigationBar.swift
//  ColorMatchTabs
//
//  Created by Sergey Butenko on 15/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

@IBDesignable class VerticalGradientView: UIView {
    
    @IBInspectable var topColor: UIColor = .white {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable var bottomColor: UIColor = .black {
        didSet {
            updateColors()
        }
    }

    fileprivate let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override var frame: CGRect {
        didSet {
            updateSize()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            updateSize()
        }
    }
    
}

private extension VerticalGradientView {
    
    func commonInit() {
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func updateColors() {
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    }
    
    func updateSize() {
        gradientLayer.frame = bounds
    }
    
}
