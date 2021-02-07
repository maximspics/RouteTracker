//
//  UIViewController+EXt.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 15.01.2021.
//

import Foundation
import UIKit

extension UIViewController {
    func showErrorMessage (message: String, title: String? = "Ошибка", handler: ((UIAlertAction) -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: handler)
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true)
    }
}
