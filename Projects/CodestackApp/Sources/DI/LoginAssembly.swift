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
        container.register(LoginViewController.self) { resolver in
            let loginViewModel = resolver.resolve((any LoginViewModelProtocol).self)!
            let apple = resolver.resolve(AppleLoginManager.self)!
            let dp = LoginViewController.Dependencies.init(viewModel: loginViewModel,
                                                           appleManager: apple)
            return LoginViewController.create(with: dp)
        }
    }
}
