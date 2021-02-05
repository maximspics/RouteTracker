//
//  PresentAnimatedTransitioning.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 01.02.2021.
//

import UIKit

final class PresentAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let animationDuration: Double
    
    init(duration: Double) {
        animationDuration = duration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let finalFrameToVC = transitionContext.finalFrame(for: toVC)
        
        toVC.view.frame = CGRect(origin: CGPoint(x: 0, y: finalFrameToVC.height), size: finalFrameToVC.size)
        containerView.addSubview(toVC.view)
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            toVC.view.frame = finalFrameToVC
        }) { success in
            transitionContext.completeTransition(success)
        }
    }
}
