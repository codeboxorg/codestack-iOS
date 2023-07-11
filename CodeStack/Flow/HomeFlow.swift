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
        self.rootViewController
    }
    
    private var rootViewController: HomeViewController
    var sideMenuViewController: SideMenuViewController
    
    
    let testScreen = TestViewController()
        
    init(dependencies: any HomeViewModelProtocol){
        
        sideMenuViewController = SideMenuViewController(sideMenuItems: SideMenuViewController.items())
        rootViewController = ViewController.create(with: HomeViewController.Dependencies(homeViewModel: dependencies,
                                                                                         sidemenuVC: sideMenuViewController))
    }
    
    
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        
        switch codestackStep {
        case .logout:
            return .end(forwardToParentFlowWithStep: CodestackStep.logout)
        case .firstHomeStep:
            return .none
        case .problemList:
            return navigateToProblemList()
        case .problemPick(_):
            return navigateToCodeEditor()
        case .problemComplete:
            return .none
        case .alert(_):
            return .none
        case .fakeStep:
            return .none
        case .sideMenuDelegate(_):
            return .none
        case .sideShow:
            return showSideMenuView()
        case .sideDissmiss:
            return dismissSideMenuView()
        case .profilePage:
            return navigateToProfileViewController()
        default:
            print("codestackStep: \(codestackStep)")
            return .none
        }
    }
    
    
    private func navigateToProblemList() -> FlowContributors{
        let viewModel = CodeProblemViewModel(DummyData())
        
        let viewController = CodeProblemViewController.create(with: .init(viewModel: viewModel))
        
        self.rootViewController.navigationController?.pushViewController(viewController, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: viewController,
                                                 withNextStepper: viewModel))
    }
    
    private func navigateToCodeEditor() -> FlowContributors{
        
        let editorvc = CodeEditorViewController()
        self.rootViewController.navigationController?.pushViewController(editorvc, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: editorvc, withNextStepper: DefaultStepper()))
        
    }
    
    private func showSideMenuView() -> FlowContributors{
        sideMenuViewController.show()
        return .none
    }
    
    private func dismissSideMenuView() -> FlowContributors{
        sideMenuViewController.hide()
        return .none
    }
    
    
    private func navigateToProfileViewController() -> FlowContributors{
        let profileVC = MyPageViewController()
        
        self.rootViewController.navigationController?.pushViewController(profileVC, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: profileVC, withNextStepper: DefaultStepper()))
    }
}

