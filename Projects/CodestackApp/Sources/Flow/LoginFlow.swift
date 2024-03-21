//
//  LoginFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/07.
//

import RxFlow
import RxSwift
import RxCocoa
import Global
import Domain

class LoginFlow: Flow {
    
    var root: Presentable {
        return self.loginViewController
    }
    
    struct Dependency {
        let injector: Injectable
    }
    
    private let injector: Injectable
    
    private var disposeBag = DisposeBag()
    
    private var loginStepper: LoginStepper
    
    private var loginViewController: LoginViewController
    
    init(dependency: Dependency,
         stepper: LoginStepper) {
        self.loginStepper = stepper
        self.injector = dependency.injector
        self.loginViewController = injector.resolve(LoginViewController.self)
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let _step = step as? CodestackStep else {return .none}
        switch _step{
        case .loginNeeded:
            return .none
            
        case .logout:
            // TODO: 바꿔야됌
            // UserManager.shared.logout { // KeychainItem.deleteToken() // }
            injector.container.resetObjectScope(.home)
            self.loginViewController.view.subviews.forEach { $0.isHidden = false }
            self.loginViewController.navigationController?.popViewController(animated: true)
            return .none
            
        case .userLoggedIn( _,  _):
            return navigateToHomeViewController()
            
        case .register:
            return navigateToRegisterViewController()
        
        case .registerDissmiss:
            self.loginViewController.navigationController?.popViewController(animated: true)
            return .none
            
        case .registerSuccess(let memberVO):
            // MARK: Welcom View 띄우기
            self.loginViewController.view.subviews.forEach { $0.isHidden = true }
            self.loginViewController.navigationController?.popToRootViewController(animated: false)
            injector.container.resetObjectScope(.register)
            return navigateToHomeViewController()
            
        default:
            return .none
        }
    }
    
    private func navigateToRegisterViewController() -> FlowContributors {
        let registerFlow = RegisterFlow(injector: injector)
        let viewmodel = injector.resolve(RegisterViewModel.self)
        Flows.use(registerFlow, when: .created) { root in
            self.loginViewController.navigationController?.isNavigationBarHidden = true
            self.loginViewController.navigationController?.pushViewController(root, animated: false)
        }
        let composite = CompositeStepper(steppers: [ OneStepper(withSingleStep: CodestackStep.register),
                                                     viewmodel])
        return .one(flowContributor:
                .contribute (
                    withNextPresentable: registerFlow,
                    withNextStepper: composite
                )
        )
    }
    
    private func navigateToHomeViewController() -> FlowContributors {
        
        let dependency = TabBarFlow.Dependency(
            injector: self.injector
        )
        
        let flow = TabBarFlow(dependency: dependency)
        
        let tabBarStepper = TabBarStepper()
        
        Flows.use(flow, when: .ready, block: { root in
            if let rootVC = root as? CustomTabBarController {
                rootVC.stepper = tabBarStepper
            }
            self.loginViewController.navigationController?.isNavigationBarHidden = true
            self.loginViewController.navigationController?.pushViewController(root, animated: false)
        })

        return .one(flowContributor: .contribute(withNextPresentable: flow,
                                                 withNextStepper: tabBarStepper))
    }
}


final class LoginStepper: Stepper {
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    // TODO: Data Layer 의존성 제거해야됨
    private var authUsecase: AuthUsecase
    
    init(authUsecase: AuthUsecase) {
        self.authUsecase = authUsecase
    }
    
    var initialStep: Step{
        CodestackStep.none
    }
    
    func readyToEmitSteps() {
        _ = authUsecase
            .firebaseTokenReissue()
            .subscribe(with: self,
                       onCompleted: { stepper in
                Log.debug("readyToEmitSteps ->")
                stepper.steps.accept(CodestackStep.userLoggedIn(nil, nil))
            }, onError: { stepper, error in
                Log.debug("readyToEmitSteps -> \(error)")
                //stepper.steps.accept(CodestackStep.userLoggedIn(nil, nil))
            })
    }
}
