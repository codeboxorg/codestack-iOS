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
import Global
import Domain
import SafariServices

class HomeStepper: Stepper {
    
    var steps = PublishRelay<Step>()
    
    var initialStep: Step {
        CodestackStep.projectHomeStep
    }
}


class HomeFlow: Flow {
    
    var root: Presentable {
        rootViewController
    }
    
    private let rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.view.backgroundColor = UIColor.systemBackground
        viewController.setNavigationBarHidden(false, animated: false)
        return viewController
    }()
    
    private var sideVC: SideMenuViewController
    
    struct Dependency{
        var tabbarDelegate: TabBarDelegate
        let injector: Injectable
    }
    
    private weak var tabbarDelegate: TabBarDelegate?
    private let injector: Injectable
    
    init(dependency: Dependency) {
        self.tabbarDelegate = dependency.tabbarDelegate
        self.injector = dependency.injector
        self.sideVC = injector.resolve(SideMenuViewController.self)
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        switch codestackStep {
            
        case .projectHomeStep:
            return navigateToHome()
            
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
            
        case .toastMessage(let message):
            return toastMessage(message)
            
        case .loginNeeded:
            return .end(forwardToParentFlowWithStep: CodestackStep.logout)
            
        case .logout:
            return .end(forwardToParentFlowWithStep: CodestackStep.logout)
            
        case .recentSolveList(let item):
            return navigateToRecentSolveList(editor: item)
            
        case .richText(let markdown, let storeVO):
            let vc = injector.resolve(RichTextViewController.self,
                                      markdown,
                                      storeVO,
                                      RichViewModel.ViewType.posting)
            rootViewController.pushViewController(vc, animated: true)
            return .none
            
        case .historyflow:
            tabbarDelegate?.setSelectedItem(for: .history)
            return .none
            
        default:
            return .none
        }
    }

    private func navigateToHome() -> FlowContributors {
        let homeVC = injector.resolve(HomeViewController.self)
        let homeViewModel = injector.resolve(HomeViewModel.self)
        
        rootViewController.pushViewController(homeVC, animated: false)
                
        let composite = CompositeStepper(steppers: [homeViewModel,sideVC])
        return .one(flowContributor: .contribute(withNextPresentable: homeVC,
                                                 withNextStepper: composite))
    }
    
    private func navigateToRecentSolveList(editor: EditorTypeProtocol) -> FlowContributors {
        let editorVC = injector.resolve(CodeEditorViewController.self, editor)
        let stepper = injector.resolve(CodeEditorStepper.self)
        editorVC.hidesBottomBarWhenPushed = true
        rootViewController.pushViewController(editorVC, animated: true)
        let composite = CompositeStepper(steppers: [stepper, editorVC])
        return .one(flowContributor: .contribute(withNextPresentable: editorVC,
                                                 withNextStepper: composite))
    }
    
    private func toastMessage(_ msg: String) -> FlowContributors {
        Toast.toastMessage("\(msg)",
                           container: rootViewController.presentedViewController?.view,
                           offset: Position.screenHeihgt - 150,
                           background: .sky_blue,
                           boader: UIColor.black.cgColor)
        return .none
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

