//
//  AppManager.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 29.01.2021.
//

import UIKit

final class AppManager {
    static let shared = AppManager()
    
    var coordinator: BaseCoordinator?
    var notificationCenter = UNUserNotificationCenter.current()
    var isNotificationGranted: Bool = false
    var userService = UserService.shared
    
    init() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            
            switch settings.authorizationStatus {
            case .authorized, .ephemeral, .provisional:
                self.isNotificationGranted = true
                
            default:
                self.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (granted, _) in
                    guard let self = self else { return }
                    self.isNotificationGranted = granted
                }
            }
        }
    }
    
    var blurView: UIView? {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        if let rootViewController = rootViewController {
            blurView.frame = rootViewController.view.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.tag = 1001
            
            return blurView
        } else {
            return nil
        }
    }
    
    var rootViewController: UIViewController? {
        return coordinator?.getRootViewController()
    }
    
    var isBlurEffectWasShown: Bool {
        guard let rootViewController = rootViewController,
            rootViewController.view.viewWithTag(1001) != nil else {
                return false
        }
        
        return true
    }
    
    func start() {
        coordinator = ApplicationCoordinator()
        coordinator?.start()
    }
    
    func didShowBlurWhenInnactive() {
        if let rootViewController = rootViewController, let blurView = blurView {
            if isBlurEffectWasShown == false {
                rootViewController.view.addSubview(blurView)
            }
            
        }
    }
    
    func didHideBlurWhenActive() {
        if isBlurEffectWasShown, let viewWithTag = rootViewController?.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func loadAvatarUrl() -> String? {
        guard let userLogin = UserDefaults.standard.string(forKey: "userLogin"),
              let user = userService.getUserBy(login: userLogin) else { return nil }
        print(user.avatarUrl)
        print(user)
        return user.avatarUrl
    }
    
    func saveAvatarToDisk(avatar: UIImage) {
        guard let userLogin = UserDefaults.standard.string(forKey: "userLogin") else { return }
        
        if let imageData = avatar.pngData(),
           var avatarFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            avatarFilePath.appendPathComponent("Avatar_\(userLogin).jpeg")
            
            try? imageData.write(to: avatarFilePath)
            userService.updateUserAvatar(with: userLogin, urlAvatar: "\(avatarFilePath)")
            
        }
    }
    
    func resizeAvatar(_ avatar: UIImage, newSize: CGSize? = CGSize(width: 80, height: 80)) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: newSize!.width, height: newSize!.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize!, false, 1.0)
        avatar.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
