//
//  MainViewControllerFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/08.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa

class HomeFlow: Flow{
    
    var root: RxFlow.Presentable{
        self.containerViewController
    }
    
    private let rootViewController: UINavigationController = {
        let nav = UINavigationController()
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }()
    
    
    lazy var containerViewController = ContainerViewController(sideMenuViewController: sideMenuViewController,rootViewController: mainVC)
    
    let codeVC = CodeProblemViewController.create(with: .init(delegate: nil,
                                                              viewModel: CodeProblemViewModel() as (any ProblemViewModelProtocol) ))
    
    let testViewController = TestViewController()
    let mainVC = ViewController()
    
    lazy var items: [SideMenuItem] = [SideMenuItem(icon: UIImage(named: "problem"),
                                              name: "문제",
                                              viewController: .push(codeVC)),
                                 SideMenuItem(icon: UIImage(named: "submit"),
                                              name: "제출근황",
                                              viewController: .modal(codeVC)),
                                 SideMenuItem(icon: UIImage(named: "my"),
                                              name: "마이 페이지",
                                              viewController: .embed(codeVC)),
                                 SideMenuItem(icon: UIImage(named: "home"),
                                              name: "메인 페이지",
                                              viewController: .embed(mainVC)),
                                 SideMenuItem(icon: nil, name: "추천", viewController: .push(testViewController))]
    
    lazy var sideMenuViewController = SideMenuViewController(sideMenuItems: items)
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        
        switch codestackStep {
        case .problemList:
            return .none
        case .problemPick(let _):
            return .none
        case .alert(let _):
            return .none
        case .fakeStep:
            return .none
        case .unauthorized:
            return .none
        case .loginNeeded:
            return .none
        case .sideMenuDelegate(let _):
            return .none
        default:
            return .none
        }
    }
    
    private func navigateToProblemList() -> FlowContributors{
        
        return .none
    }
}
