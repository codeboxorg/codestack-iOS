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
import Swinject

class HistoryFlow: Flow {
    
    var root: Presentable{
        rootViewController
    }
    
    private let injector: Injectable
    
    init(injector: Injectable) {
        self.injector = injector
    }
    
    private let rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.view.backgroundColor = UIColor.systemBackground
        viewController.setNavigationBarHidden(false, animated: false)
        return viewController
    }()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        switch codestackStep{
        case .historyflow:
            return navigateToHistory()
        case .logout:
            injector.container.resetObjectScope(.history)
            return .none
        default:
            return .none
        }
    }
    
    func navigateToHistory() -> FlowContributors{
        let history = injector.resolve(HistoryViewController.self)
        history.navigationItem.title = "기록"
        rootViewController.pushViewController(history, animated: false)
        return .none
    }
    
}



