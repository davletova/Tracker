//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Алия Давлетова on 27.07.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        let tabBar = UITabBarController()
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width:tabBar.tabBar.frame.size.width, height: 1))
        lineView.backgroundColor = UIColor.getAppColors(.tabBarBorder)
        tabBar.tabBar.addSubview(lineView)
        
        let navigationController = UINavigationController(rootViewController: TrackerCollectionView())
        navigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "record.circle.fill"),
            tag: 0
        )
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "hare.fill"),
            tag: 1
        )
        tabBar.setViewControllers([navigationController, statisticsViewController], animated: true)
        
        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

