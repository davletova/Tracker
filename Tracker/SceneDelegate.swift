//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Алия Давлетова on 27.07.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let defaults = UserDefaults.standard
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
      
        if !defaults.bool(forKey: isOnbordingShown) {
            let onboarding = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            window?.rootViewController = onboarding
        } else {
            let tabBar = StartViewController()

            window?.rootViewController = tabBar
        }
        
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

