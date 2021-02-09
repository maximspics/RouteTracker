//
//  AppDelegate.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 15.01.2021.
//

import UIKit
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appManager = AppManager()
    let googleMapsApiKey = "AIzaSyDmf1FFaUqimaGFoBgxxyA_8sum1LUQwJE"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(googleMapsApiKey)
        if #available(iOS 13, *) {
        } else {
            window = UIWindow()
            window?.makeKeyAndVisible()
            appManager.start()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @available(iOS 12.0, *)
    func applicationWillResignActive(_ application: UIApplication) {
        appManager.didShowBlurWhenInnactive()
        
        let notify = Notification()
        notify.send(title: "Route Tracker", subtitle: "Ждем тебя!", content: "Пора на тренировку")
    }
    
    @available(iOS 12.0, *)
    func applicationDidBecomeActive(_ application: UIApplication) {
        appManager.didHideBlurWhenActive()
    }

}

