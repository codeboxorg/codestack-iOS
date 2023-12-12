//
//  CodeEditorAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/12/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Network


public struct CodeEditorAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(CodeEditorViewModel.self) { resolver in
            let home = resolver.resolve(HomeViewModel.self)!
            let history = resolver.resolve(HistoryViewModel.self)!
            let useCase = resolver.resolve(SubmissionUseCase.self)!
            
            let dp = CodeEditorViewModel.Dependency(homeViewModel: home,
                                                    historyViewModel: history,
                                                    submissionUseCase: useCase)
            return CodeEditorViewModel(dependency: dp)
        }.inObjectScope(.container)
        
        
        container.register(CodeEditorViewController.self) { resolver, problemListItem in
            let viewModel = resolver.resolve(CodeEditorViewModel.self)!
            
            let dp = CodeEditorViewController.Dependency.init(viewModel: viewModel,
                                                              problem: problemListItem)
            return CodeEditorViewController.create(with: dp)
        }
    }
    
    
}