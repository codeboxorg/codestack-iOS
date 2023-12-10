//
//  CodeStackFlow.swift
//  CodeStack
//
//  Created by 박형환 on 12/1/23.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa

final class CodeStackFlow: Flow {
    var root: Presentable {
        codestackVC
    }
    
    let codestackVC = CodeStackViewController()
    
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? CodestackStep else { return .none }
        switch step {
        case .codestack:
            return navigateToCodestackVC()
        default:
            return .none
        }
    }
    
    private func navigateToCodestackVC() -> FlowContributors {
        .one(flowContributor: .contribute(withNextPresentable: codestackVC,
                                          withNextStepper: OneStepper(withSingleStep: CodestackStep.codestack)))
    }
    
}
