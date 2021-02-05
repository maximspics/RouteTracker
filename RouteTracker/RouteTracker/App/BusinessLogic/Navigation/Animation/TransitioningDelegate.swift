//
//  TransitioningDelegate.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 01.02.2021.
//

import UIKit

final class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    static let shared = TransitioningDelegate()
    var animationDuration = 0.29
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimatedTransitioning(duration: animationDuration)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimatedTransitioning(duration: animationDuration)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
