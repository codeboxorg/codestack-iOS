//
//  MyPageFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/13.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa


class MyPageFlow: Flow{
    
    var root: Presentable{
        rootViewController
    }
    
    private let rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(true, animated: true)
        return viewController
    }()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        switch codestackStep{
        case .profilePage:
            return navigateToMyPage()
        default:
            return .none
        }
    }
    
    func navigateToMyPage() -> FlowContributors {
        Log.debug("navigateToMyPage")
        let profileVC = MyPageViewController()
        self.rootViewController.pushViewController(profileVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: profileVC, withNextStepper: DefaultStepper()))
    }
    
}
