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
import Domain
import SafariServices

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
        viewController.view.backgroundColor = UIColor.systemBackground
        viewController.setNavigationBarHidden(false, animated: true)
        return viewController
    }()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        switch codestackStep {
        case .problemList:
            return navigateToProblemList()
            
        case .problemLink(let url):
            self.rootViewController.pushViewController(SFSafariViewController(url: url), animated: false)
            return .none
            
        case .problemPick(let editor):
            rootViewController.tabBarController?.tabBar.isHidden = true
            return navigateToProblemPick(editor: editor)
            
        case .problemComplete:
            rootViewController.tabBarController?.tabBar.isHidden = false
            rootViewController.setNavigationBarHidden(false, animated: true)
            rootViewController.popViewController(animated: true)
            return .none
        
        case .toastV2Message(let style, let message):
            let value = ToastValue.make(style, message)
            Toast.toastMessage(value,pos: .top, xOffset: 12, yOffset: -120)
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
        default:
            return .none
        }
    }
    
    func navigateToProblemList() -> FlowContributors{
        let problemVC = injector.resolve(CodeProblemViewController.self)
        rootViewController.pushViewController(problemVC, animated: false)
        
        return .one(flowContributor: .contribute(withNextPresentable: problemVC,
                                                 withNextStepper: problemVC.viewModel as! CodeProblemViewModel))
    }
    
    
    func navigateToProblemPick(editor: EditorTypeProtocol) -> FlowContributors{
        let editorVC = injector.resolve(CodeEditorViewController.self, editor)
        let stepper = injector.resolve(CodeEditorStepper.self)
        editorVC.hidesBottomBarWhenPushed = true
        rootViewController.pushViewController(editorVC, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: editorVC, withNextStepper: stepper))
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
