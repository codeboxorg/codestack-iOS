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
    
    private let rootViewController = UINavigationController()
    
    private lazy var loginViewController: LoginViewController = {
        let viewModel = LoginViewModel(service: self.loginService)
        let dp = LoginViewController.Dependencies(viewModel: viewModel)
        let vc = LoginViewController.create(with: dp)
        return vc
    }()
    
    init(loginService: OAuthrizationRequest){
        self.loginService = loginService
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let _step = step as? CodestackStep else {return .none}
        switch _step{
        case .loginNeeded:
            print("loginFLow navigate  .loginNeeded")
            return .none
        case .userLoggedIn:
            return .none
        default:
            return .none
        }
    }
    
    private func navigateToLoginViewController() -> FlowContributors {
        let loginVC = loginViewController
        self.rootViewController.pushViewController(loginVC, animated: false)
        return .one(flowContributor: .contribute(withNext: loginVC))
    }
}
