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
    
    struct Dependency {
        let loginService: OAuthrizationRequest
        let appleLoginManager: AppleLoginManager
        let apolloService: ApolloServiceType
        let authService: AuthServiceType
    }
    
    private let loginService: OAuthrizationRequest
    private let appleLoginManager: AppleLoginManager
    private let apolloService: ApolloServiceType
    private let authService: AuthServiceType
    
    private var disposeBag = DisposeBag()
    
    private var loginStepper: LoginStepper
    
    private lazy var loginViewController: LoginViewController = {
        let dependency = LoginViewModel.Dependency(loginService: self.loginService,
                                                   apolloService: self.apolloService,
                                                   stepper: self.loginStepper)
        let viewModel = LoginViewModel(dependency: dependency)
        let dp = LoginViewController.Dependencies(viewModel: viewModel,appleManager: appleLoginManager)
        let vc = LoginViewController.create(with: dp)
        return vc
    }()
    
    init(dependency: Dependency,
         stepper: LoginStepper) {
        
        self.appleLoginManager = dependency.appleLoginManager
        self.loginService = dependency.loginService
        self.authService = dependency.authService
        self.apolloService = dependency.apolloService
        self.loginStepper = stepper
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let _step = step as? CodestackStep else {return .none}
        switch _step{
        case .loginNeeded:
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
        
        let registerViewController = RegisterViewController.create(with: self.authService)
        
        registerViewController.adjustLargeTitleSize(title: "회원가입")
        self.loginViewController.navigationController?.isNavigationBarHidden = false
        self.loginViewController.navigationController?.pushViewController(registerViewController, animated: false)
        return .one(flowContributor: .contribute(withNext: registerViewController))
    }
    
    
    private func navigateToHomeViewController() -> FlowContributors{
        
        let dependency = TabBarFlow.Dependency(loginservice: self.loginService,
                                               authService: self.authService,
                                               apolloService: self.apolloService)
        
        let flow = TabBarFlow(dependency: dependency)
        
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
        
        let accessToken = KeychainItem.currentAccessToken
        let refreshToken = KeychainItem.currentRefreshToken
        
        Log.debug("accessToken: \(accessToken)")
        Log.debug("accessToken: \(refreshToken)")
        
        if KeychainItem.currentAccessToken.isEmpty{
            steps.accept(CodestackStep.none)
        }else{
            steps.accept(CodestackStep.userLoggedIn(nil, nil))
        }
    }
    
}
