//
//  AppFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/07.
//

import UIKit
import RxFlow
import RxCocoa
import RxSwift

class AppFlow: Flow{
    
    var root: Presentable {
        self.rootViewController
    }
    
    private let loginService: OAuthrizationRequest
    private let appleService: AppleLoginManager
    
    init(loginService: OAuthrizationRequest,appleService: AppleLoginManager){
        self.loginService = loginService
        self.appleService = appleService
    }

    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(true, animated: false)
        return viewController
    }()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        
        Log.debug(step)
        switch codestackStep{
        case .loginNeeded:
            return navigateToLoginVC()
        default:
            return .none
        }
    }
    
    private func navigateToLoginVC() -> FlowContributors{
        let loginStepper = LoginStepper()
        let loginFlow = LoginFlow(loginService: self.loginService,appleLogin: appleService, stepper: loginStepper)
        
        Flows.use(loginFlow, when: .created, block: { root in
            self.rootViewController.pushViewController(root, animated: false)
        })
        return .one(flowContributor: .contribute(withNextPresentable: loginFlow, withNextStepper: loginStepper))
    }   
}

class AppStepper: Stepper{
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    
    var initialStep: Step{
        CodestackStep.loginNeeded
    }
    
    func readyToEmitSteps() {
        
    }
}
