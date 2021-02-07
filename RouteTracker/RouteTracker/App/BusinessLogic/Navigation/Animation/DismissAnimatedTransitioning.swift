//
//  DismissAnimatedTransitioning.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 01.02.2021.
//

import UIKit

final class DismissAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    private let animationDuration: Double
    
    init(duration: Double) {
        animationDuration = duration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let presentingViewWasRemoved = fromVC.presentationController?.shouldRemovePresentersView ?? false
        if presentingViewWasRemoved {
            let containerView = transitionContext.containerView
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        }
        
        let duration = transitionDuration(using: transitionContext)
        let finalFrameToVC = transitionContext.finalFrame(for: fromVC)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            fromVC.view.frame = CGRect(origin: CGPoint(x: 0, y: finalFrameToVC.height), size: finalFrameToVC.size)
        }) { success in
            fromVC.view.removeFromSuperview()
            transitionContext.completeTransition(success)
        }
    }
}
