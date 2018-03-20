//
//  AppDelegate.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var navigationViewController: UINavigationController = { [unowned self] in
        let navigationViewController = UINavigationController(rootViewController: self.rootViewController)
        return navigationViewController
    }()
    
    lazy var rootViewController: UIViewController = {
        let viewModel = GithubRepositoriesViewModel()
        let viewController = GithubListViewController.create(with: viewModel)
        return viewController
    }()
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        initWindow()
        return true
    }
    
    func initWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationViewController
        window?.makeKeyAndVisible()
    }
}
