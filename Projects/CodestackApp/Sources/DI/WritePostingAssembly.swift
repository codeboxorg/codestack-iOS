//
//  WritePostingAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 3/5/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import Swinject
import Domain

public struct WritePostingAssembly: Assembly {
    
    public func assemble(container: Container) {
        container.register(WriteSelectViewController.self) { resolver in
            return WriteSelectViewController()
        }
        
        container.register(WritePostingViewModel.self) { resolver in
            let profileUsecase = resolver.resolve(ProfileUsecase.self)!
            let firebaseUsecase = resolver.resolve(FirebaseUsecase.self)!
            
            let dependency: WritePostingViewModel.Dependency
            = .init(profileUsecase: profileUsecase, firebaseUsecase: firebaseUsecase)
            
            return WritePostingViewModel(dependency: dependency)
        }.inObjectScope(.weak)
        
        container.register(WritePostingViewController.self) { resolver in
            let vm = resolver.resolve(WritePostingViewModel.self)!
            return WritePostingViewController.create(with: vm)
        }
        
        container.register(TagSeletedViewController.self) { resolver in
            let vm = resolver.resolve(WritePostingViewModel.self)!
            return TagSeletedViewController.create(with: vm)
        }
    }
}
