//
//  MypageAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Data
import Domain

public struct MyPageAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(MyPageViewModel.self) { resolver in
            let auth = resolver.resolve(RestAPI.self)!
            let web = resolver.resolve(WebRepository.self)!
            
            let dp = MyPageViewModel.Dependency(authService: auth,
                                                apolloService: web)
            return MyPageViewModel(dependency: dp)
        }
        
        container.register(MyPageViewController.self) { resolver in
            let viewModel = resolver.resolve(MyPageViewModel.self)!
            return MyPageViewController.create(with: viewModel)
        }
    }
}
