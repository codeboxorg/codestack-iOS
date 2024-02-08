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
        
        Flows.use(flow, when: .ready, block: { root in
            self.loginViewController.navigationController?.isNavigationBarHidden = true
            self.loginViewController.navigationController?.pushViewController(root, animated: false)
        })

        return .one(flowContributor: .contribute(withNextPresentable: flow,
                                                 withNextStepper: OneStepper(withSingleStep: CodestackStep.firstHomeStep)))
    }
}


class LoginStepper: Stepper {
    
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
                stepper.steps.accept(CodestackStep.userLoggedIn(nil, nil))
            }, onError: { stepper, error in
                Log.debug("readyToEmitSteps -> \(error)")
                //stepper.steps.accept(CodestackStep.userLoggedIn(nil, nil))
            })
    }
    
//    func readyToEmitSteps() {
//         TODO: Reissue Token Error
//         현재 refresh TOken 으로 재발급시 서버측 Token(구버젼) 으로 발급이 되어 에러 발생 -> 현재는 명시적으로 로그인 하도록
//        let accessToken = KeychainItem.currentAccessToken
//        let refreshToken = KeychainItem.currentRefreshToken
//        
//        let token = authService.reissueToken(token: RefreshToken(refresh: refreshToken))
//        
//        _ = token.subscribe(with: self, onNext: { stepper , value in
//            let (response,data) = value
//            switch response.statusCode {
//            case 200..<299:
//                do {
//                    let reissueToken = try API.extract(data)
//                    try KeychainItem.saveAccessToken(access: reissueToken)
//                    stepper.steps.accept(CodestackStep.userLoggedIn(nil, nil))
//                } catch {
//                    Log.error(error)
//                }
//            default:
//                stepper.steps.accept(CodestackStep.none)
//            }
//        })
//    }
}
