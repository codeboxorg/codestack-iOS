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
    
    private let serviceManager: OAuthrizationRequest = ServiceManager()
    
    var coordinator: FlowCoordinator = FlowCoordinator()
    var disposeBag: DisposeBag = DisposeBag()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windoScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windoScene)

        
        let flow = AppFlow(loginService: self.serviceManager)
        self.coordinator.coordinate(flow: flow, with: AppStepper())
        
        Flows.use(flow, when: .created, block: { root in
            window.rootViewController = root
            window.makeKeyAndVisible()
        })
        
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
                    .flatMap{self.serviceManager.request(with: $0, provider: .github)}
                    .observe(on: MainScheduler.instance)
                    .subscribe(onSuccess: {
                        print("onSuccess")
                    }).disposed(by: disposeBag)
            }
            
            
        }
    }
    
}

