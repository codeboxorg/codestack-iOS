//
//  LoginFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/07.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa

class LoginFlow: Flow{
    
    var root: Presentable {
        return self.loginViewController
    }
    
    private weak var loginService: OAuthrizationRequest?
    private weak var appleLoginManager: AppleLoginManager?
    private var disposeBag = DisposeBag()
    
    var loginStepper: LoginStepper
    
    private lazy var loginViewController: LoginViewController = {
        let viewModel = LoginViewModel(service: self.loginService,stepper: loginStepper)
        let dp = LoginViewController.Dependencies(viewModel: viewModel,appleManager: appleLoginManager)
        let vc = LoginViewController.create(with: dp)
        return vc
    }()
    
    init(loginService: OAuthrizationRequest,
         appleLogin: AppleLoginManager,
         stepper: LoginStepper){
        self.appleLoginManager = appleLogin
        self.loginService = loginService
        self.loginStepper = stepper
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let _step = step as? CodestackStep else {return .none}
        switch _step{
        case .loginNeeded:
            print("loginFLow navigate  .loginNeeded")
            return .none
        case .logout:
            self.loginViewController.navigationController?.popViewController(animated: true)
            return .none
        case .userLoggedIn( _,  _):
            return navigateToHomeViewController()
        case .register:
            return navigateToRegisterViewController()
            
        default:
            return .none
        }
    }
    
    private func navigateToRegisterViewController() -> FlowContributors {
        
        guard let service = self.loginService else { return .none }
        let registerViewController = RegisterViewController.create(with: service)
        
        registerViewController.adjustLargeTitleSize(title: "회원가입")
        self.loginViewController.navigationController?.isNavigationBarHidden = false
        self.loginViewController.navigationController?.pushViewController(registerViewController, animated: false)
        return .one(flowContributor: .contribute(withNext: registerViewController))
    }
    
    
    private func navigateToHomeViewController() -> FlowContributors{
        guard let loginService else {return .none}
        let flow = TabBarFlow(dependency: loginService)
        
        Flows.use(flow, when: .ready, block: { root in
            self.loginViewController.navigationController?.isNavigationBarHidden = true
            self.loginViewController.navigationController?.pushViewController(root, animated: false)
        })

        return .one(flowContributor: .contribute(withNextPresentable: flow,
                                                 withNextStepper: OneStepper(withSingleStep: CodestackStep.firstHomeStep)))
    }
}


class LoginStepper: Stepper{
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    
    var initialStep: Step{
        CodestackStep.none
    }
    
    func readyToEmitSteps() {
        
        if KeychainItem.currentAccessToken.isEmpty{
            steps.accept(CodestackStep.none)
        }else{
            steps.accept(CodestackStep.userLoggedIn(nil, nil))
        }
    }
    
}
