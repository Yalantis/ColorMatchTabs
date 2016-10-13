//
//  CircleTransitionAnimator.swift
//  ColorMatchTabs
//
//  Created by anna on 6/20/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

open class CircleTransition: NSObject {
    
    public enum Mode {
        case show, hide
    }
    
    open var startPoint: CGPoint!
    open var duration: TimeInterval = 0.15
    open var mode: Mode!
    
    fileprivate weak var transitionContext: UIViewControllerContextTransitioning?

}

extension CircleTransition: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }

        transitionContext.containerView.addSubview(toViewController.view)
        
        let needShow = mode == .show
        if !needShow {
            transitionContext.containerView.addSubview(fromViewController.view)
        }
        
        let animatedViewController = needShow ? toViewController : fromViewController
        let initialRect = CGRect(origin: startPoint, size: CGSize.zero)
        let initialCircleMaskPath = UIBezierPath(ovalIn: initialRect)
        let extremePoint = CGPoint(x: startPoint.x, y: animatedViewController.view.bounds.height)
        let radius = hypot(extremePoint.x, extremePoint.y)
        let finalCircleMaskPath = UIBezierPath(ovalIn: initialRect.insetBy(dx: -radius, dy: -radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = needShow ? finalCircleMaskPath.cgPath : initialCircleMaskPath.cgPath
        animatedViewController.view.layer.mask = maskLayer
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = initialCircleMaskPath.cgPath
        maskLayerAnimation.fromValue = needShow ? initialCircleMaskPath.cgPath : finalCircleMaskPath.cgPath
        maskLayerAnimation.toValue = needShow ? finalCircleMaskPath.cgPath : initialCircleMaskPath.cgPath
        maskLayerAnimation.delegate = self
        maskLayerAnimation.duration = transitionDuration(using: transitionContext)
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }

}

extension CircleTransition: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let transitionContext = transitionContext else {
            return
        }
        
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view.layer.mask = nil
    }
    
}
