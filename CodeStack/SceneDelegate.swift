//
//  SceneDelegate.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let serviceManager: OAuthrizationRequest = ServiceManager()
    var appleLoginManager: AppleLoginManager?
    var disposeBag: DisposeBag = DisposeBag()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windoScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windoScene)
        window.makeKeyAndVisible()
        
        let viewModel = LoginViewModel(service: serviceManager)
        
        let dependencies = LoginViewController.Dependencies(viewModel: viewModel)
        let vc = LoginViewController.create(with: dependencies)
        
        let navigationController = UINavigationController(rootViewController: vc)
        appleLoginManager = AppleLoginManager(vc)
        vc.appleLoginManager = appleLoginManager
        
        window.rootViewController = navigationController
        
        self.window = window
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            
            
            //MARK: - Github url open
            let component = url.absoluteString.components(separatedBy: "?")
            if let flag = component.first?.elementsEqual("codestackiosclient://login"),
               flag,
               let code = component.last?.components(separatedBy: "=").last{
                
                serviceManager
                    .request(code: code)
                    .subscribe(onSuccess: { token in
                        print("token : \(token)")
                    }, onError: { err in
                        
                    }, onCompleted: {
                        
                    }, onDisposed: {
                        
                    }).disposed(by: disposeBag)
                
            }
            
            
        }
    }
    
}

