//
//  MainViewControllerFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/08.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import Global
import Domain

final class TabBarStepper: Stepper {
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    
    var initialStep: Step {
        CodestackStep.firstHomeStep
    }
}

final class TabBarFlow: Flow {
    
    var root: Presentable {
        self.rootViewTabController
    }
    
    struct Dependency {
        let injector: Injectable
    }
    
    private let injector: Injectable
    
    init(dependency: Dependency){
        self.injector = dependency.injector
    }
    
    private var rootViewTabController = CustomTabBarController()
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        switch codestackStep {
        case .logout:
            return .end(forwardToParentFlowWithStep: CodestackStep.logout)
        
        case .firstHomeStep:
            return navigateToTabBarController()
            
        case .toastV2Message(let style, let message):
            let value = ToastValue.make(style, message)
            Toast.toastMessage(value,pos: .top, xOffset: 12, yOffset: -80)
            return .none
            
        case .writeSelectStep:
            return navigateToShowSelectVC()
        
        case .codeEditorStep(let editor):
            return navigateCodeEditorVC(editor)
            
        case .postingWrtieStep:
            return navigateToWritePostingVC()        
            
        case .postingEndStep:
            return .none
            
        case let .richText(html, storeVO):
            showPreviewRichText(html, storeVO)
            
        case .problemComplete:
            self.rootViewTabController
                .selectedViewController?
                .navigationController?
                .popViewController(animated: true)
            return .none
            
        case .problemList:
            rootViewTabController.selectedIndex = 1
            return .none
        default:
            return .none
        }
        return .none
    }
    
    private func showPreviewRichText(_ html: String, _ storeVO: StoreVO) {
        let vc = injector.resolve(RichTextViewController.self,
                                  html,
                                  storeVO,
                                  RichViewModel.ViewType.preview)
        
        self.rootViewTabController
            .selectedViewController?
            .navigationController?
            .pushViewController(vc, animated: false)
    }
    
    private func navigateToWritePostingVC() -> FlowContributors {
        let viewController = injector.resolve(WritePostingViewController.self)
        viewController.modalPresentationStyle = .fullScreen
        viewController.hidesBottomBarWhenPushed = true
        //viewController.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.rootViewTabController.selectedViewController?.dismiss(animated: true)
        
        self.rootViewTabController
            .selectedViewController?
            .navigationController?
            .pushViewController(viewController, animated: true)
        
        return .one(flowContributor:
                .contribute(withNextPresentable: viewController,
                            withNextStepper: viewController.viewModel)
        )
    }
    
    private func navigateToShowSelectVC() -> FlowContributors {
        let postingVC = WriteSelectViewController()
        postingVC.modalPresentationStyle = .automatic
        postingVC.sheetPresentationController?.detents = [.medium(), .large()]
        
        self.rootViewTabController.selectedViewController?
            .navigationController?
            .present(postingVC, animated: true)
        
        return .one(flowContributor: .contribute(withNext: postingVC))
    }
    
    private func navigateCodeEditorVC(_ editor: EditorTypeProtocol) -> FlowContributors {
        let editorVC = injector.resolve(CodeEditorViewController.self, editor)
        let stepper = injector.resolve(CodeEditorStepper.self)
        editorVC.hidesBottomBarWhenPushed = true
        
        self.rootViewTabController.selectedViewController?.dismiss(animated: true)
        
        self.rootViewTabController
            .selectedViewController?
            .navigationController?
            .pushViewController(editorVC, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: editorVC, withNextStepper: stepper))
    }
    
    private func navigateToTabBarController() -> FlowContributors {
        let tabBarDelegate = rootViewTabController
        
        let codeDependency = CodeProblemFlow.Dependency(
            injector: injector
        )
        
        let homeDependency = HomeFlow.Dependency(
            tabbarDelegate: tabBarDelegate,
            injector: injector
        )
        
        let myPageDependency = MyPageFlow.Dependency(
            injector: injector
        )
        
        let homeFlow = HomeFlow(dependency: homeDependency)
        let problemFlow = CodeProblemFlow(dependency: codeDependency)
        let historyFlow = HistoryFlow(injector: injector)
        let myPageFlow = MyPageFlow(dependency: myPageDependency)
        
        Flows.use(homeFlow,problemFlow,historyFlow,myPageFlow, when: .created)
        { [unowned self] home,problem,histoty,myPage in
            let homeVC = home
            let problemVC = problem
            let historyVC = histoty
            let myPageVC = myPage
            
            let dummyViewConroller = MockViewController()
            self.rootViewTabController.setViewControllers([homeVC, problemVC,dummyViewConroller, historyVC, myPageVC], animated: true)
            rootViewTabController.addTabBarItems()
        }
        
        return .multiple(flowContributors: [
            .contribute(withNextPresentable: homeFlow, 
                        withNextStepper: HomeStepper()),
            
            .contribute(withNextPresentable: problemFlow,
                        withNextStepper: ProblemStepper()),
            
            .contribute(withNextPresentable: historyFlow,
                        withNextStepper: OneStepper(withSingleStep: CodestackStep.historyflow)),
            
            .contribute(withNextPresentable: myPageFlow,
                        withNextStepper: OneStepper(withSingleStep: CodestackStep.profilePage))
        ])
    }
}


