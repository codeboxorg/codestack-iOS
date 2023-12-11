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
    
    struct Dependency {
        let loginService: OAuthrizationRequest
        let appleService: AppleLoginManager
        let authService: AuthServiceType
    }
    
    private let loginService: OAuthrizationRequest
    private let appleService: AppleLoginManager
    private let authService: AuthServiceType
    private lazy var apolloService: WebRepository = DefaultApolloRepository(dependency: authService.tokenService)
    
    
    init(dependency: Dependency){
        self.loginService = dependency.loginService
        self.appleService = dependency.appleService
        self.authService = dependency.authService
    }

    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(true, animated: false)
        return viewController
    }()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        
        switch codestackStep{
        case .loginNeeded:
            return navigateToLoginVC()
        case .onBoardingRequired:
            return navigateToOnBoarding()
        case .onBoardingComplte:
            return dismissOnBoarding()
        default:
            return .none
        }
    }

    private func navigateToLoginVC() -> FlowContributors{
        let loginStepper = LoginStepper(authService: self.authService)
        
        let dependecy = LoginFlow.Dependency(loginService: self.loginService,
                                             appleLoginManager: self.appleService,
                                             apolloService: self.apolloService,
                                             authService: self.authService)
        
        let loginFlow = LoginFlow(dependency: dependecy, stepper: loginStepper)
        
        Flows.use(loginFlow, when: .created, block: { root in
            self.rootViewController.pushViewController(root, animated: false)
        })
        return .one(flowContributor: .contribute(withNextPresentable: loginFlow, withNextStepper: loginStepper))
    }
    
    private func navigateToOnBoarding() -> FlowContributors{
    
        let onBoardingFlow = OnBoardingFlow()
        
        Flows.use(onBoardingFlow, when: .created){ [unowned self] root in
            DispatchQueue.main.async {
                root.modalPresentationStyle = .fullScreen
                self.rootViewController.present(root, animated: false)
            }
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: onBoardingFlow,
                                                 withNextStepper: OneStepper(withSingleStep: CodestackStep.onBoardingRequired)))
    }
    
    private func dismissOnBoarding() -> FlowContributors{
        if let vc = self.rootViewController.presentedViewController{
            vc.dismiss(animated: true)
        }
        return .none
    }
    
}

class AppStepper: Stepper{
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    
    var initialStep: Step{
        CodestackStep.loginNeeded
    }
    
    func readyToEmitSteps() {
        steps.accept(CodestackStep.onBoardingRequired)
    }
}