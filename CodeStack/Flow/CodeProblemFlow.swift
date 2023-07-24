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
        case .problemPick(_):
            rootViewController.tabBarController?.tabBar.isHidden = true
            return navigateToProblemPick()
        case .problemComplete:
            rootViewController.tabBarController?.tabBar.isHidden = false
            rootViewController.setNavigationBarHidden(false, animated: true)
            rootViewController.popViewController(animated: true)
            return .none
        default:
            return .none
        }
    }
    
    func navigateToProblemList() -> FlowContributors{
        let codeViewModel = CodeProblemViewModel(DummyData())
        let problemVC = CodeProblemViewController.create(with: .init(viewModel: codeViewModel))
        
        rootViewController.pushViewController(problemVC, animated: false)
        
        return .one(flowContributor: .contribute(withNextPresentable: problemVC,
                                                 withNextStepper: codeViewModel))
    }
    
    
    func navigateToProblemPick() -> FlowContributors{
        let editorvc = CodeEditorViewController()
        rootViewController.pushViewController(editorvc, animated: true)
        
        return .one(flowContributor: .contribute(withNext: editorvc))
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
