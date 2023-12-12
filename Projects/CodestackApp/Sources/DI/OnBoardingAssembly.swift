//
//  OnBoardingAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject

public struct OnBoardingAssembly: Assembly {
    
    public func assemble(container: Container) {
        container.register(PagingOnboardingViewController.self) { resolver in
            return PagingOnboardingViewController.init()
        }
    }
}
