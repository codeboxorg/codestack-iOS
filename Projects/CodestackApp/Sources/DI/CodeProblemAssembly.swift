//
//  CodeProblemAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Domain

public struct CodeProblemAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(CodeProblemViewModel.self) { resolver in
            let usecase = resolver.resolve(ProblemUsecase.self)!
            return CodeProblemViewModel(AnimateProblemModel(), usecase)
        }
        
        container.register(CodeProblemViewController.self) { resolver in
            let viewModel = resolver.resolve(CodeProblemViewModel.self)!
            let dp = CodeProblemViewController.Dependencies.init(viewModel: viewModel)
            return CodeProblemViewController.create(with: dp)
        }
        
    }
    
}
