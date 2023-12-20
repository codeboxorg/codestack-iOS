//
//  HistoryAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Domain


extension ObjectScope {
    static let history = ObjectScope(storageFactory: PermanentStorage.init)
}

public struct HistoryAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(HistoryViewModel.self) { resolver in
            let usecase = resolver.resolve(HistoryUsecase.self)!
            let home = resolver.resolve(HomeViewModel.self)!
            let dp = HistoryViewModel.Dependency.init(submisionUsecase: usecase,
                                                      homeViewModel: home,
                                                      container: container)
            return HistoryViewModel(dependency: dp)
        }.inObjectScope(.history)
        
        container.register(HistoryViewController.self) { resolver in
            let viewModel = resolver.resolve(HistoryViewModel.self)!
            let historyViewModelType = viewModel as any HistoryViewModelType
            return HistoryViewController.create(with: historyViewModelType)
        }
    }
}
