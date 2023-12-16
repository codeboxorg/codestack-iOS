//
//  MypageAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Domain

public struct MyPageAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(MyPageViewModel.self) { resolver in
            let useCase = resolver.resolve(ProfileUsecase.self)!
            let dp = MyPageViewModel.Dependency(profileUsecase: useCase)
            return MyPageViewModel(dependency: dp)
        }
        
        container.register(MyPageViewController.self) { resolver in
            let viewModel = resolver.resolve(MyPageViewModel.self)!
            return MyPageViewController.create(with: viewModel)
        }
    }
}
