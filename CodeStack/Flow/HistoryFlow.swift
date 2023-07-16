//
//  HistoryFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/13.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa


class HistoryFlow: Flow{
    
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
        case .historyflow:
            return navigateToHistory()
        default:
            return .none
        }
    }
    
    func navigateToHistory() -> FlowContributors{
        let testVC = TestViewController()
        rootViewController.pushViewController(testVC, animated: false)
        return .none
    }
    
}



