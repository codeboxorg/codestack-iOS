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
        let injector: Injectable
    }
    
    private let injector: Injectable
    
    init(dependency: Dependency){
        injector = dependency.injector
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
            rootViewController.tabBarController?.tabBar.isHidden = true
            return navigateToProblemPick(problem: problem)
            
        case .problemComplete:
            rootViewController.tabBarController?.tabBar.isHidden = false
            rootViewController.setNavigationBarHidden(false, animated: true)
            rootViewController.popViewController(animated: true)
            return .none
            
        case .toastMessage(let message):
            Toast.toastMessage("\(message)",
                               container: rootViewController.presentedViewController?.view,
                               offset: UIScreen.main.bounds.height - 150,
                               background: .sky_blue,
                               boader: UIColor.black.cgColor)
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
        let problemVC = injector.resolve(CodeProblemViewController.self)
        let codeViewModel = injector.resolve(CodeProblemViewModel.self)
        rootViewController.pushViewController(problemVC, animated: false)
        
        return .one(flowContributor: .contribute(withNextPresentable: problemVC,
                                                 withNextStepper: codeViewModel))
    }
    
    
    func navigateToProblemPick(problem: ProblemListItemModel) -> FlowContributors{
//        let editorvc = injector.resolve(CodeEditorViewController.self, problem)
        
//        let stepper = injector.resolve(CodeEditorStepper.self)
        let stepper = CodeEditorStepper.init()
        let home = injector.resolve(HomeViewModel.self)
        let his = injector.resolve(HistoryViewModel.self)
        let sub = injector.resolve(SubmissionUseCase.self)
        
        let dp1 = CodeEditorViewModel.Dependency.init(homeViewModel: home,
                                                     historyViewModel: his,
                                                     submissionUseCase: sub,
                                                     stepper: stepper)
        
        let viewModel = CodeEditorViewModel(dependency: dp1)
        
        let dp = CodeEditorViewController.Dependency(viewModel: viewModel,
                                                     problem: problem)
        
        let editorvc = CodeEditorViewController.create(with: dp)
        
        editorvc.hidesBottomBarWhenPushed = true
        rootViewController.pushViewController(editorvc, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: editorvc, withNextStepper: stepper))
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
