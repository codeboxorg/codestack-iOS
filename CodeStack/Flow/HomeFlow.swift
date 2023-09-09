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
                                                                           presentation: .recentSolveList(nil)),
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
                                                                           name: "로그아웃", presentation: .logout)])

    
    struct Dependency{
        var tabbarDelegate: TabBarDelegate
        var apolloService: ApolloServiceType
        var homeViewModel: (any HomeViewModelType)
        var historyViewModel: (any HistoryViewModelType)
    }
    
    private weak var tabbarDelegate: TabBarDelegate?
    private let apolloService: ApolloServiceType
    private let homeViewModel: (any HomeViewModelType)
    private let historyViewModel: (any HistoryViewModelType)
    
    init(dependency: Dependency){
        self.apolloService = dependency.apolloService
        self.homeViewModel = dependency.homeViewModel
        self.tabbarDelegate = dependency.tabbarDelegate
        self.historyViewModel = dependency.historyViewModel
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
            
        case .recommendPage:
            Toast.toastMessage("...현재 지원하지 않는 기능입니다...",
                               offset: UIScreen.main.bounds.height - 250,
                               background: .sky_blue,
                               boader: UIColor.black.cgColor)
            return .none
            
        case .problemList:
            //main -> problem (Move Tab 1)
            tabbarDelegate?.setSelectedItem(for: .problem)
            return .none
            
        case .problemComplete:
            rootViewController.setNavigationBarHidden(false, animated: true)
            rootViewController.popViewController(animated: true)
            return .none
            
        case .logout:
            return .end(forwardToParentFlowWithStep: CodestackStep.logout)
            
        case .recentSolveList(let item):
            
            guard let item else {return .none}
            return navigateToRecentSolveList(problem: item)
            
        case .historyflow:
            tabbarDelegate?.setSelectedItem(for: .history)
            return .none
            
        default:
            return .none
        }
    }
    
    private func navigateToHome() -> FlowContributors{
        let homeViewModel = self.homeViewModel
        
        let homeVC = ViewController.create(with: HomeViewController.Dependencies(homeViewModel: homeViewModel,
                                                                                         sidemenuVC: sideVC))
        rootViewController.pushViewController(homeVC, animated: false)
                
        return .one(flowContributor: .contribute(withNextPresentable: homeVC,
                                                 withNextStepper: CompositeStepper(steppers: [homeViewModel,sideVC])))
    }
    
    private func navigateToRecentSolveList(problem item: ProblemListItemModel) -> FlowContributors
    {
        let viewModelDependency = CodeEditorViewModel.Dependency(service: apolloService,
                                                                 homeViewModel: homeViewModel,
                                                                 historyViewModel: historyViewModel)
        let viewModel = CodeEditorViewModel(dependency: viewModelDependency)
        let dependency = CodeEditorViewController.Dependency(viewModel: viewModel, problem: item)
        let editorvc = CodeEditorViewController.create(with: dependency)
        editorvc.hidesBottomBarWhenPushed = true
        rootViewController.pushViewController(editorvc, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: editorvc, withNextStepper: viewModel))
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

