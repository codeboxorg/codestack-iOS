//
//  RegisterFlow.swift
//  CodestackApp
//
//  Created by 박형환 on 1/19/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import Global

import CommonUI

final class RegisterFlow: Flow {
    
    var root: Presentable {
        self.rootViewController
    }
    
    private let injector: Injectable
    
    init(injector: Injectable) {
        self.injector = injector
    }
    
    lazy var rootViewController: RegisterViewController = injector.resolve(RegisterViewController.self)
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else { return .none }
        switch codestackStep {
        case .register:
            return .none
            
        case .registerDissmiss(let member):
            // self.rootViewController.navigationController?.popToRootViewController(animated: true)
            Log.debug("member: \(member)")
            return .end(forwardToParentFlowWithStep: CodestackStep.registerSuccess(member))
            
        case .email:
            return .none
            
        case .password:
            return navigatePasswordInfoVC()
            
        case .additionalInfo:
            return navigateAdditionalInfoVC()
            
        case .toastV2Message(let type, let msg):
            let value = ToastValue.make(type, msg)
            Toast.toastMessage(value,pos: .top, xOffset: 12, yOffset: -120)
            return .none
            
        case .exitRegister:
            self.rootViewController.navigationController?.popViewController(animated: false)
            // injector.container.resetObjectScope(.register)
            return .none
        default:
            return .none
        }
    }
    
    private func navigatePasswordInfoVC() -> FlowContributors {
        let passwordVC = injector.resolve(PasswordViewController.self)
        let registerViewModel = injector.resolve(RegisterViewModel.self)
        rootViewController.navigationController?.pushViewController(passwordVC, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: passwordVC,
                                                 withNextStepper: registerViewModel.step1))
    }
    
    private func navigateAdditionalInfoVC() -> FlowContributors {
        let additionalInfoVC = injector.resolve(AdditionalInfoViewController.self)
        let registerViewModel = injector.resolve(RegisterViewModel.self)
        rootViewController.navigationController?.pushViewController(additionalInfoVC, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: additionalInfoVC,
                                                 withNextStepper: registerViewModel.step2))
    }
    
    
}
