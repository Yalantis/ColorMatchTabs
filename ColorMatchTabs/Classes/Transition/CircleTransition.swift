//
//  CircleTransitionAnimator.swift
//  ColorMatchTabs
//
//  Created by anna on 6/20/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

public class CircleTransition: NSObject {
    
    public enum Mode {
        case Show, Hide
    }
    
    public var startPoint: CGPoint!
    public var duration: NSTimeInterval = 0.15
    public var mode: Mode!
    
    private weak var transitionContext: UIViewControllerContextTransitioning?

}

extension CircleTransition: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
        fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            containerView = transitionContext.containerView() else {
            return
        }
        containerView.addSubview(toViewController.view)
        
        let needShow = mode == .Show
        if !needShow {
            containerView.addSubview(fromViewController.view)
        }
        
        let animatedViewController = needShow ? toViewController : fromViewController
        let initialRect = CGRect(origin: startPoint, size: CGSize.zero)
        let initialCircleMaskPath = UIBezierPath(ovalInRect: initialRect)
        let extremePoint = CGPoint(x: startPoint.x, y: animatedViewController.view.bounds.height)
        let radius = hypot(extremePoint.x, extremePoint.y)
        let finalCircleMaskPath = UIBezierPath(ovalInRect: CGRectInset(initialRect, -radius, -radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = needShow ? finalCircleMaskPath.CGPath : initialCircleMaskPath.CGPath
        animatedViewController.view.layer.mask = maskLayer
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = initialCircleMaskPath.CGPath
        maskLayerAnimation.fromValue = needShow ? initialCircleMaskPath.CGPath : finalCircleMaskPath.CGPath
        maskLayerAnimation.toValue = needShow ? finalCircleMaskPath.CGPath : initialCircleMaskPath.CGPath
        maskLayerAnimation.delegate = self
        maskLayerAnimation.duration = transitionDuration(transitionContext)
        maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
    }
    
    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        guard let transitionContext = transitionContext else {
            return
        }
        
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view.layer.mask = nil
    }

}