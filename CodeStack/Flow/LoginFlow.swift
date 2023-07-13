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
//    private let rootViewController = UINavigationController()
    
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
        case .userLoggedIn(let _, let _):
            return navigateToHomeViewController()
        default:
            return .none
        }
    }
    
//    private func navigateToLoginViewController() -> FlowContributors {
//        let loginVC = loginViewController
//        self.rootViewController.pushViewController(loginVC, animated: false)
//        return .one(flowContributor: .contribute(withNext: loginVC))
//    }
    
    private func navigateToHomeViewController() -> FlowContributors{
        let viewModel = HomeViewModel()
        let flow = HomeFlow(dependencies: viewModel)
        let stepper = HomeStepper()
        
        Flows.use(flow, when: .ready, block: { root in
            self.loginViewController.navigationController?.setNavigationBarHidden(false, animated: true)
            self.loginViewController.navigationController?.pushViewController(root, animated: false)
        })

        return .one(flowContributor: .contribute(withNextPresentable: flow,
                                                 withNextStepper: CompositeStepper(steppers: [viewModel,stepper,flow.sideMenuViewController])))
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
