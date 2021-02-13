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
        let controller = UIStoryboard(name: "Map", bundle: nil)
            .instantiateViewController(MapViewController.self)
        
        controller.onWorkoutList = { [weak self] in
            self?.showWorkoutListModule()
        }
        
        controller.onWorkoutDetails = { [weak self] (activityID: String, title: String) in
            self?.showWorkoutDetailModule(activityID, title)
        }
        
        controller.onSettings = { [weak self] in
            self?.showSettingsModule()
        }
        
        controller.onLogout = { [weak self] in
            self?.onFinishFlow?()
        }
        
        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
        self.mapViewController = controller
    }
    
    private func showWorkoutListModule() {
        let controller = UIStoryboard(name: "Workout", bundle: nil)
            .instantiateViewController(WorkoutListViewController.self)
        
        controller.onWorkoutDetails = { [weak self] (activityID: String, title: String) in
            self?.showWorkoutDetailModule(activityID, title)
        }
        
        controller.didWorkoutDelete = { [weak self] activityID in
            self?.mapViewController?.onWorkoutDelete(activityID)
        }
        
        let transitioningDelegate = TransitioningDelegate.shared
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = transitioningDelegate
        
        rootController?.present(controller, animated: true)
    }
    
    private func showWorkoutDetailModule(_ activityID: String, _ title: String) {
        let controller = UIStoryboard(name: "Workout", bundle: nil)
            .instantiateViewController(WorkoutDetailViewController.self)
        
        controller.activityID = activityID
        controller.workoutTitle = title
        
        controller.didWorkoutSelect = { [weak self] activityID in
            self?.mapViewController?.onWorkoutSelect(activityID)
        }
        
        let transitioningDelegate = TransitioningDelegate.shared
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = transitioningDelegate
        
        rootController?.present(controller, animated: true)
    }
    
    private func showSettingsModule() {
        let controller = UIStoryboard(name: "Settings", bundle: nil)
            .instantiateViewController(SettingsViewController.self)
        
        controller.didAvatarChanged = { [weak self] avatar in
            self?.mapViewController?.onAvatarChanged(avatar)
        }
        
        let transitioningDelegate = TransitioningDelegate.shared
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = transitioningDelegate
        
        rootController?.present(controller, animated: true)
    }
}

