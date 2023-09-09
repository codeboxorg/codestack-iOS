//
//  ProblemFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/13.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa


class CodeProblemFlow: Flow{
    
    var root: Presentable{
        rootViewController
    }
    
    struct Dependency{
        var apolloService: ApolloServiceType
        var homeViewModel: (any HomeViewModelType)
        var historyViewModel: (any HistoryViewModelType)
    }
    
    private let apolloService: ApolloServiceType
    private let homeViewModel: any HomeViewModelType
    private let historyViewModel: any HistoryViewModelType
    
    init(dependency: Dependency){
        self.apolloService = dependency.apolloService
        self.homeViewModel = dependency.homeViewModel
        self.historyViewModel = dependency.historyViewModel
    }
    
    private let rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(false, animated: true)
        return viewController
    }()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        switch codestackStep{
        case .problemList:
            return navigateToProblemList()
        case .problemPick(let problem):
            Log.debug(problem)
            rootViewController.tabBarController?.tabBar.isHidden = true
            return navigateToProblemPick(problem: problem)
            
        case .problemComplete:
            rootViewController.tabBarController?.tabBar.isHidden = false
            rootViewController.setNavigationBarHidden(false, animated: true)
            rootViewController.popViewController(animated: true)
            return .none
        case .loginNeeded:
            return .end(forwardToParentFlowWithStep: CodestackStep.logout)
            
        case .richText(let problems):
            
            let vc = RichTextViewController.create(with: problems)
            
            self.rootViewController.show(vc, sender: nil)
            
            return .none
        default:
            return .none
        }
    }
    
    func navigateToProblemList() -> FlowContributors{
        let codeViewModel = CodeProblemViewModel(DummyData(),apolloService)
        let problemVC = CodeProblemViewController.create(with: .init(viewModel: codeViewModel))
        
        rootViewController.pushViewController(problemVC, animated: false)
        
        return .one(flowContributor: .contribute(withNextPresentable: problemVC,
                                                 withNextStepper: codeViewModel))
    }
    
    
    func navigateToProblemPick(problem: ProblemListItemModel) -> FlowContributors{
        
        let viewModelDependency = CodeEditorViewModel.Dependency(service: self.apolloService,
                                                                 homeViewModel: self.homeViewModel,
                                                                 historyViewModel: self.historyViewModel)
        let viewModel = CodeEditorViewModel(dependency: viewModelDependency)
        let dependency = CodeEditorViewController.Dependency(viewModel: viewModel,
                                                             problem: problem)
        let editorvc = CodeEditorViewController.create(with: dependency)
        editorvc.hidesBottomBarWhenPushed = true
        rootViewController.pushViewController(editorvc, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: editorvc, withNextStepper: viewModel))
    }
    
}


class ProblemStepper: Stepper{
    
    var steps = PublishRelay<RxFlow.Step>()
    
    var initialStep: Step{
        CodestackStep.problemList
    }
    
    @objc func dissmissEditor(_ sender: Any){
        steps.accept(CodestackStep.problemComplete)
    }
}
