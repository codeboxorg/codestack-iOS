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
    
    
    let codeProblemViewModel: any ProblemViewModelProtocol
    lazy var codeProblemVC = CodeProblemViewController.create(with: .init(viewModel: codeProblemViewModel))
    
    init(dependencies: any ProblemViewModelProtocol){
        self.codeProblemViewModel = dependencies
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        
        return .none
    }
    
    
}

class CodeProblemStepper: Stepper{
    var steps = PublishRelay<RxFlow.Step>()
    
    var initialStep: Step{
        CodestackStep.problemList
    }
    
    
}
