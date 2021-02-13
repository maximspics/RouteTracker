//
//  UIViewController+EXt.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 15.01.2021.
//

import Foundation
import UIKit

extension UIViewController {
    func showMessage(message: String, title: String? = "", handler: ((UIAlertAction) -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: handler)
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true)
    }
    
    func showSelfDisappearingMessage(_ message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

                alertController.dismiss(animated: true, completion: nil)
            }
    }
}
