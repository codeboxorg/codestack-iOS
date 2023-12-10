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
    
    var coordinator: FlowCoordinator = FlowCoordinator()
    var disposeBag: DisposeBag = DisposeBag()

    private let loginService: OAuthrizationRequest = LoginService()
    private let authService: AuthServiceType = AuthService()
    private lazy var appleLoginManger: AppleLoginManager = AppleLoginManager(serviceManager: self.loginService as AppleAuthorization)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windoScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windoScene)
        
        let appDependency = AppFlow.Dependency(loginService: self.loginService,
                                               appleService: self.appleLoginManger,
                                               authService: self.authService)
        
        let flow = AppFlow(dependency: appDependency)
        
        self.coordinator.coordinate(flow: flow, with: AppStepper())
        
        Flows.use(flow, when: .created, block: { root in
            window.rootViewController = root
            window.makeKeyAndVisible()
        })
        self.window = window
    }
    
    
    
    /// Git Auth 과정에서 redirect 되었을때 호출되는 함수
    /// - Parameters:
    ///   - scene: 현재의 scene
    ///   - URLContexts: app build setting에서 정의한 URL Type으로 redirect 된다.
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        Log.debug("\(URLContexts)")
        if let url = URLContexts.first?.url {
            //MARK: - Github url open
            
            let component = url.absoluteString.components(separatedBy: "?")
            if let flag = component.first?.elementsEqual("codestackios://git/auth"),
               flag,
               let code = component.last?.components(separatedBy: "=").last{
                (loginService as GitOAuthorization).gitOAuthComplete(code: code)
            }
        }
    }
    
}

