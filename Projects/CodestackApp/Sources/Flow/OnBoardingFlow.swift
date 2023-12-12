//
//  OnBoardingFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/14.
//

import UIKit
import RxFlow

class OnBoardingFlow: Flow{
    
    var root: Presentable{
        rootViewController
    }
    
    var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.navigationBar.topItem?.title = "OnBoarding"
        return viewController
    }()
    
    struct Dependency {
        let injector: Injectable
    }
    
    private let injector: Injectable
    
    
    init(dependency: Dependency) {
        self.injector = dependency.injector
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard
            let codeStep = step as? CodestackStep
        else { Log.error("Step unwrappingError");  return .none}
        switch codeStep{
        case .onBoardingRequired:
            return navigateToOnBoardingVC()
        case .onBoardingComplte:
            return .end(forwardToParentFlowWithStep: CodestackStep.onBoardingComplte)
        default:
            return .none
        }
    }
    
    private func navigationToLoginScreen() -> FlowContributors {
        return .none
    }
    
    func navigateToOnBoardingVC() -> FlowContributors{
        let vc = injector.resolve(PagingOnboardingViewController.self)
        rootViewController.pushViewController(vc, animated: false)
        return .one(flowContributor: .contribute(withNext: vc))
        
//        let onBoarding = OnBoardingVC()
//
//        Log.debug(rootViewController.isNavigationBarHidden)
//
//        rootViewController.pushViewController(onBoarding, animated: false)
//
//        return .one(flowContributor: .contribute(withNext: onBoarding))
    }
}
