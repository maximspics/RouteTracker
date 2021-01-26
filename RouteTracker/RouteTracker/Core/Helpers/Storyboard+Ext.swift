//
//  Storyboard+Ext.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 26.01.2021.
//

import Foundation
import UIKit

// Протокол для объектов, имеющих идентификатор в сториборде
protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

// Расширение UIViewController,
// которое даёт совместимость с протоколом StoryboardIdentifiable
extension UIViewController: StoryboardIdentifiable { }

// Расширение протокола StoryboardIdentifiable для UIViewController,
// создающее идентификатор в сториборде, равный названию класса контроллера
extension StoryboardIdentifiable where Self: UIViewController {
    
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIStoryboard {
    
    func instantiateViewController<T: UIViewController>(_: T.Type) -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("View controller с идентификатором \(T.storyboardIdentifier) не найден")
        }
        
        return viewController
    }
    
    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("View controller с идентификатором \(T.storyboardIdentifier) не найден")
        }
        
        return viewController
    }
}
