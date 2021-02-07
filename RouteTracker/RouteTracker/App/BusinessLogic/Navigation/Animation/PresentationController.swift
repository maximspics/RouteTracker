//
//  PresentationController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 01.02.2021.
//

import UIKit

final class PresentationController: UIPresentationController {
    
    override var shouldRemovePresentersView: Bool {
        return true
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(origin: CGPoint(x: 0, y: 0), size: presentingViewController.view.frame.size)
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
}
