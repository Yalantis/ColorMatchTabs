//
//  CAAnimation+OpacityAnimation.swift
//  ColorMatchTabs
//
//  Created by anna on 6/16/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

extension CAAnimation {
    
    static func opacityAnimation(withDuration duration: Double, initialValue: Float, finalValue: Float) -> CAAnimation {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        opacityAnimation.fromValue = initialValue
        opacityAnimation.toValue = finalValue

        return opacityAnimation
    }
    
}