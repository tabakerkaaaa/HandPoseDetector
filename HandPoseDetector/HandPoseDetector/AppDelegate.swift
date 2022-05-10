//
//  AppDelegate.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private lazy var coordinator: Coordinatable = {
        CoordinatorFactory.makeAppCoordinator(
            router: Router(
                rootController: rootController
            )
        )
    }()
    
    private lazy var rootController: UINavigationController = {
        let navigationController = UINavigationController()
        window = UIWindow()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return navigationController
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        coordinator.start()
        return true
    }
}

