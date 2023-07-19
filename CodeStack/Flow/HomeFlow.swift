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
    
    private var sideVC = SideMenuViewController()

    
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
            
        case .recentSolveList:
            return navigateToRecentSolveList()
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
                                                 withNextStepper: homeViewModel))
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

