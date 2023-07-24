//
//  SceneDelegate.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import RxSwift
import RxFlow

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private let serviceManager: OAuthrizationRequest = LoginService()
    
    var coordinator: FlowCoordinator = FlowCoordinator()
    var disposeBag: DisposeBag = DisposeBag()
    lazy var appleLoginManger: AppleLoginManager = AppleLoginManager(serviceManager: self.serviceManager as AppleAuthorization)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windoScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windoScene)

        
        let flow = AppFlow(loginService: self.serviceManager,appleService: appleLoginManger)
        self.coordinator.coordinate(flow: flow, with: AppStepper())
        
        Flows.use(flow, when: .created, block: { root in
            window.rootViewController = root
            window.makeKeyAndVisible()
        })
        self.window = window
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        Log.debug("\(URLContexts)")
        if let url = URLContexts.first?.url {
            //MARK: - Github url open
            
            let component = url.absoluteString.components(separatedBy: "?")
            if let flag = component.first?.elementsEqual("codestackios://git/auth"),
               flag,
               let code = component.last?.components(separatedBy: "=").last{
                (serviceManager as GitOAuthorization).gitOAuthComplete(code: code)
            }
        }
    }
    
}

