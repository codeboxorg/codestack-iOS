//
//  SceneDelegate.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windoScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windoScene)
        window.makeKeyAndVisible()
        
        let codeVC = CodeProblemViewController()
        
        let mainVC = ViewController()
        let items: [SideMenuItem] = [SideMenuItem(icon: UIImage(named: "problem"),
                                                  name: "문제",
                                                  viewController: .push(codeVC)),
                                     SideMenuItem(icon: UIImage(named: "submit"),
                                                  name: "제출근황",
                                                  viewController: .modal(codeVC)),
                                     SideMenuItem(icon: UIImage(named: "my"),
                                                  name: "마이 페이지",
                                                  viewController: .embed(codeVC)),
                                     SideMenuItem(icon: UIImage(named: "home"),
                                                  name: "메인 페이지",
                                                  viewController: .embed(mainVC))]
        
        let sideMenuViewController = SideMenuViewController(sideMenuItems: items)
        let containerViewController = ContainerViewController(sideMenuViewController: sideMenuViewController,
                                                              rootViewController: mainVC)
        window.rootViewController = containerViewController
        
        self.window = window
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

