//
//  LoginAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject

public struct LoginAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(LoginStepper.self) { resolver in
            let service = resolver.resolve(AuthServiceType.self)!
            return LoginStepper(authService: service)
        }.inObjectScope(.container)
        
        container.register((any LoginViewModelProtocol).self) { resolver in
            let request = resolver.resolve(OAuthrizationRequest.self)!
            let web = resolver.resolve(WebRepository.self)!
            let stepper = resolver.resolve(LoginStepper.self)!
            
            let dp = LoginViewModel.Dependency(loginService: request,
                                               apolloService: web,
                                               stepper: stepper)
            return LoginViewModel(dependency: dp)
        }.inObjectScope(.container)
        
        container.register(LoginViewController.self) { resolver in
            let loginViewModel = resolver.resolve((any LoginViewModelProtocol).self)!
            let apple = resolver.resolve(AppleLoginManager.self)!
            let dp = LoginViewController.Dependencies.init(viewModel: loginViewModel,
                                                           appleManager: apple)
            return LoginViewController.create(with: dp)
        }
    }
}
