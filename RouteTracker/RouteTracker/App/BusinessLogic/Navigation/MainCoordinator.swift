//
//  MainCoordinator.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 26.01.2021.
//

import Foundation
import UIKit

final class MainCoordinator: BaseCoordinator {
    
    var rootController: UINavigationController?
    var mapViewController: MapViewController?
    var onFinishFlow: (() -> Void)?
    
    override func start() {
        showMapModule()
    }
    
    private func showMapModule() {
        let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(MapViewController.self)
        
        
        controller.onWorkoutList = { [weak self] in
            self?.showWorkoutListModule()
        }
        
        controller.onLogout = { [weak self] in
            self?.onFinishFlow?()
        }
        
        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }
    
    private func showMapModule(usseles: String) {
        let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(MapViewController.self)
        
        rootController?.pushViewController(controller, animated: true)
    }
    
    private func showWorkoutListModule() {
        let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(WorkoutListViewController.self)
        
        controller.didWorkoutSelect = { [weak self] activityID in
            self?.mapViewController?.onWorkoutSelect(activityID)
        }
        
        controller.didWorkoutDelete = { [weak self] activityID in
            self?.mapViewController?.onWorkoutDelete(activityID)
        }
        
        rootController?.present(controller, animated: true)
        
    }
}
