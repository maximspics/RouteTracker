//
//  AuthCoordinator.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 26.01.2021.
//

import Foundation
import UIKit

final class AuthCoordinator: BaseCoordinator {
    
    var rootController: UINavigationController?
    var onFinishFlow: (() -> Void)?
    var loginViewController: LoginViewController?
    
    override func start() {
        showLoginModule()
    }
    
    private func showLoginModule() {
        let controller = UIStoryboard(name: "Auth", bundle: nil)
            .instantiateViewController(LoginViewController.self)
        
        controller.onRegister = { [weak self] in
            self?.showRegisterModule()
        }
        
        controller.onLogin = { [weak self] in
            self?.onFinishFlow?()
        }
        
        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
        self.loginViewController = controller
    }
    
    private func showRegisterModule() {
        let controller = UIStoryboard(name: "Auth", bundle: nil)
            .instantiateViewController(RegisterViewController.self)
        
        controller.onRegistrationDone = { [weak self] in
            self?.onFinishFlow?()
        }
        
        let transitioningDelegate = TransitioningDelegate.shared
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = transitioningDelegate
        
        rootController?.present(controller, animated: true)
    }
    
}
