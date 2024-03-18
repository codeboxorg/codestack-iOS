//
//  CodeEditorAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/12/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Network
import Domain


public struct CodeEditorAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(CodeEditorStepper.self) { resolver in
            return CodeEditorStepper()
        }.inObjectScope(.container)
        
        container.register(CodeEditorViewModel.self) { resolver in
            let home = resolver.resolve(HomeViewModel.self)!
            let history = resolver.resolve(HistoryViewModel.self)!
            let useCase = resolver.resolve(SubmissionUseCase.self)!
            let stepper = resolver.resolve(CodeEditorStepper.self)!
            let codeUsecase = resolver.resolve(CodeUsecase.self)!
            let jzUsecase = resolver.resolve(JZUsecase.self)!
            
            let dp = CodeEditorViewModel.Dependency(homeViewModel: home,
                                                    historyViewModel: history,
                                                    submissionUseCase: useCase,
                                                    stepper: stepper,
                                                    codeuseCase: codeUsecase,
                                                    jzuseCase: jzUsecase)
            let editorViewModel = CodeEditorViewModel(dependency: dp)
            
            
            return editorViewModel
        }
        
        container.register(CodeEditorReactor.self) { resolver in
            return CodeEditorReactor(initialState: .init(alert: ""))
        }
        
        container.register(CodeEditorViewController.self) { resolver, editorType in
            let viewModel = resolver.resolve(CodeEditorViewModel.self)!
            let reactor = resolver.resolve(CodeEditorReactor.self)!
            let dp = CodeEditorViewController.Dependency.init(viewModel: viewModel,
                                                              editorReactor: reactor,
                                                              editorType: editorType)
            return CodeEditorViewController.create(with: dp)
        }
    }
}
