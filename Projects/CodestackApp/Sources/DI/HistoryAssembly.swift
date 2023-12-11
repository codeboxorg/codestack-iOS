//
//  HistoryAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject

public struct HistoryAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register((any HistoryViewModelType).self) { resolver in
            let webRepository = resolver.resolve(WebRepository.self)!
            let useCase = resolver.resolve(SubmissionUseCase.self)!
            let dp = HistoryViewModel.Dependency(service: webRepository, submisionUsecase: useCase)
            return HistoryViewModel(dependency: dp)
        }
        
        container.register(HistoryViewController.self) { resolver in
            let viewModel = resolver.resolve((any HistoryViewModelType).self)!
            return HistoryViewController.create(with: viewModel)
        }
    }
}
