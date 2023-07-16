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
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        switch codestackStep{
        case .firstHomeStep:
            return navigateToHome()
        case .sideShow:
            return showSideMenuView()
        case .sideDissmiss:
            return dismissSideMenuView()
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
    
    private func showSideMenuView() -> FlowContributors{
        sideVC.show()
        return .none
    }
    
    private func dismissSideMenuView() -> FlowContributors{
        sideVC.hide()
        return .none
    }
}

