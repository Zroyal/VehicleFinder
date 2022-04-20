//
//  AppDelegate.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.overrideUserInterfaceStyle = .light
                
        let vc = DefaultAppFactory().makeMapViewController()

        window?.rootViewController = vc
        
        window?.makeKeyAndVisible()

        return true
    }

}

