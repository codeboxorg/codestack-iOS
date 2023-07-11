//
//  CodeProblemFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/14.
//

import UIKit
import RxFlow
import RxRelay
import RxSwift
import RxCocoa

class CodeProblemListFlow: Flow{
    var root: RxFlow.Presentable{
        return codeProblemVC
    }
    
    var codeProblemVC: CodeProblemViewController
    
    init(dependencies: any ProblemViewModelProtocol){
        self.codeProblemVC = CodeProblemViewController.create(with: .init(viewModel: dependencies))
    }
    
    deinit{
        print("\(String(describing: Self.self)) - deinint")
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        switch codestackStep {
        case .logoutIsRequired:
            return .none
        case .problemComplete:
            print("navigate")
            return .end(forwardToParentFlowWithStep: CodestackStep.problemComplete)
        case .fakeStep:
            return .none
        default:
            return .none
        }
    }
}

class CodeProblemStepper: Stepper{
    var steps = PublishRelay<RxFlow.Step>()
    
    var initialStep: Step{
        CodestackStep.problemList
    }
    
}
