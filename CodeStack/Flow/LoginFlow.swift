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
        let apolloService: WebRepository
        let authService: AuthServiceType
    }
    
    private let loginService: OAuthrizationRequest
    private let appleLoginManager: AppleLoginManager
    private let apolloService: WebRepository
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
            UserManager.shared.logout {
                KeychainItem.deleteToken()
            }
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
    
    private var authService: AuthServiceType
    
    init(authService: AuthServiceType) {
        self.authService = authService
    }
    
    var initialStep: Step{
        CodestackStep.none
    }
    
    func readyToEmitSteps() {
//         TODO: Reissue Token Error
//         현재 refresh TOken 으로 재발급시 서버측 Token(구버젼) 으로 발급이 되어 에러 발생 -> 현재는 명시적으로 로그인 하도록
//        let accessToken = KeychainItem.currentAccessToken
//        // let refreshToken = KeychainItem.currentRefreshToken
//        
//        let token = authService.reissueToken(token: ReissueAccessToken(accessToken: accessToken))
//        
//        _ = token.subscribe(with: self, onNext: { stepper , value in
//            let (response,data) = value
//            switch response.statusCode {
//            case 200..<299:
//                do {
//                    let reissueToken = try API.extractAccessToken(data)
//                    try KeychainItem.saveAccessToken(access: reissueToken)
//                    stepper.steps.accept(CodestackStep.userLoggedIn(nil, nil))
//                } catch {
//                    Log.error(error)
//                }
//            default:
//                stepper.steps.accept(CodestackStep.none)
//            }
//        })
    }
}
