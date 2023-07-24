//
//  TabFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/16.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa


class HomeStepper: Stepper{
    
    var steps = PublishRelay<Step>()
    
    var initialStep: Step{
        CodestackStep.firstHomeStep
    }
}


class HomeFlow: Flow{
    
    var root: Presentable{
        rootViewController
    }
    
    private let rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(false, animated: false)
        return viewController
    }()
    
    private var sideVC = SideMenuViewController.create(with: [SideMenuItem(icon: UIImage(named: "problem"),
                                                                           name: "문제",
                                                                           presentation: .problemList),
                                                              SideMenuItem(icon: UIImage(named: "submit"),
                                                                           name: "제출근황",
                                                                           presentation: .recentSolveList),
                                                              SideMenuItem(icon: UIImage(named: "my"),
                                                                           name: "마이 페이지",
                                                                           presentation: .profilePage),
                                                              SideMenuItem(icon: UIImage(named: "home"),
                                                                           name: "메인 페이지",
                                                                           presentation: .none),
                                                              SideMenuItem(icon: UIImage(systemName: "hand.thumbsup"),
                                                                           name: "추천",
                                                                           presentation: .recommendPage),
                                                              SideMenuItem(icon: UIImage(systemName: "lock.open"),
                                                                           name: "logout", presentation: .logout)])

    private weak var tabbarDelegate: TabBarDelegate?
    
    
    
    init(delegate: TabBarDelegate){
        tabbarDelegate = delegate
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        switch codestackStep{
        case .firstHomeStep:
            return navigateToHome()
            
        case .sideShow:
            return showSideMenuView()
            
        case .sideDissmiss:
            return dismissSideMenuView()
            
        case .problemList:
            //main -> problem (Move Tab 1)
            tabbarDelegate?.setSelectedIndex(for: 1)
            return .none
            
        case .problemComplete:
            rootViewController.setNavigationBarHidden(false, animated: true)
            rootViewController.popViewController(animated: true)
            return .none
            
        case .logout:
            return .end(forwardToParentFlowWithStep: CodestackStep.logout)
            
        case .recentSolveList:
            return navigateToRecentSolveList()
            
        case .historyflow:
            tabbarDelegate?.setSelectedIndex(for: 2)
            return .none
            
        default:
            return .none
        }
    }
    
    private func navigateToHome() -> FlowContributors{
        let homeViewModel = HomeViewModel()
        
        let homeVC = ViewController.create(with: HomeViewController.Dependencies(homeViewModel: homeViewModel,
                                                                                         sidemenuVC: sideVC))
        rootViewController.pushViewController(homeVC, animated: false)
                
        return .one(flowContributor: .contribute(withNextPresentable: homeVC,
                                                 withNextStepper: CompositeStepper(steppers: [homeViewModel,sideVC])))
    }
    
    private func navigateToRecentSolveList() -> FlowContributors {
        let editorvc = CodeEditorViewController()
        rootViewController.pushViewController(editorvc, animated: true)
        
        return .one(flowContributor: .contribute(withNext: editorvc))
    }
    
    private func showSideMenuView() -> FlowContributors {
        sideVC.show()
        return .none
    }
    
    private func dismissSideMenuView() -> FlowContributors {
        sideVC.hide()
        return .none
    }
}

