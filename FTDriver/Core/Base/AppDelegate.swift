//
//  AppDelegate.swift
//  FTDriver
//
//  Created by Tan Dat on 25/8/24.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let viewController = MainViewController()
        
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        return true
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait // Chỉ cho phép chế độ dọc
    }

}

