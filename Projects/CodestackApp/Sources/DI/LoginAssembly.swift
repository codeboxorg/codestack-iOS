//
//  LoginAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Domain

public struct LoginAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(LoginStepper.self) { resolver in
            return LoginStepper()
        }.inObjectScope(.container)
        
        container.register(LoginViewModel.self) { resolver in
            let stepper = resolver.resolve(LoginStepper.self)!
            
            let useCase = resolver.resolve(AuthUsecase.self)!
            
            let dp = LoginViewModel.Dependency(authUsecase: useCase, stepper: stepper)
            return LoginViewModel(dependency: dp)
        }.inObjectScope(.container)
        
        container.register(LoginViewController.self) { resolver in
            let loginViewModel = resolver.resolve(LoginViewModel.self)!
//            let apple = resolver.resolve(AppleLoginManager.self)!
            let dp = LoginViewController.Dependencies.init(viewModel: loginViewModel
                                                           /*appleManager: apple*/)
            return LoginViewController.create(with: dp)
        }
    }
}
