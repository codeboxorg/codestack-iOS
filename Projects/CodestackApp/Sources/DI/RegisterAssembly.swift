//
//  RegisterAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/12/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject


public struct RegisterAssembly: Assembly {
    
    public func assemble(container: Container) {
        container.register(RegisterViewController.self) { resolver in
            let service = resolver.resolve(AuthServiceType.self)!
            return RegisterViewController.create(with: service)
        }
    }
}
