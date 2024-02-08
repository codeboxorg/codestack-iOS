//
//  RegisterAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/12/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Domain
import RxFlow
import RxRelay

final class RegisterStep1: Stepper {
    var steps = PublishRelay<Step>()
}

final class RegisterStep2: Stepper {
    var steps = PublishRelay<Step>()
}

extension ObjectScope {
    static let register = ObjectScope(storageFactory: PermanentStorage.init)
}

public struct RegisterAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(RegisterStep1.self) { resolver in
            return RegisterStep1()
        }
        
        container.register(RegisterStep2.self) { resolver in
            return RegisterStep2()
        }
        
        container.register(RegisterViewModel.self) { resolver in
            let usecase = resolver.resolve(AuthUsecase.self)!
            let registerStep1 = resolver.resolve(RegisterStep1.self)!
            let registerStep2 = resolver.resolve(RegisterStep2.self)!
            let dp = RegisterViewModel.Dependency.init(step1: registerStep1,
                                                       step2: registerStep2,
                                                       authUsecase: usecase)
            return RegisterViewModel(dependency: dp)
        }.inObjectScope(.register)
        
        container.register(RegisterViewController.self) { resolver in
            let usecase = resolver.resolve(RegisterViewModel.self)!
            let vc = RegisterViewController.create(with: usecase)
            vc.step = .email
            return vc
        }.inObjectScope(.register)
        
        container.register(PasswordViewController.self) { resolver in
            let viewmodel = resolver.resolve(RegisterViewModel.self)!
            let vc = PasswordViewController.create(with: viewmodel)
            vc.step = .password
            return vc
        }.inObjectScope(.register)
        
        container.register(AdditionalInfoViewController.self) { resolver in
            let viewmodel = resolver.resolve(RegisterViewModel.self)!
            let vc = AdditionalInfoViewController.create(with: viewmodel)
            vc.step = .nickname
            return vc
        }.inObjectScope(.register)
    }
}
