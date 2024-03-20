//
//  HomeDependency.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Domain

extension ObjectScope {
    static let home = ObjectScope(storageFactory: PermanentStorage.init)
}

public struct HomeAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        // MARK: Home ViewModel
        container.register(HomeViewModel.self) { resolver in
            let home = resolver.resolve(HomeUsecase.self)!
            let codestackUseCase = resolver.resolve(FirebaseUsecase.self)!
            let homeViewModel: HomeViewModel.Dependency = .init(homeUsecase: home,
                                                                codestackUsecase: codestackUseCase)
            return HomeViewModel(dependency: homeViewModel)
        }.inObjectScope(.home)
        
        
        // MARK: Contribution ViewModel
        container.register(ContributionViewModel.self) { resolver in
            let submissionUseCase = resolver.resolve(SubmissionUseCase.self)!
            let dependency = ContributionViewModel.Dependency(submissionUsecase: submissionUseCase)
            return ContributionViewModel.create(depenedency: dependency)
        }
        
        container.register(RichTextViewController.self) { resolver, markdown, storeVO, viewType in
            let firebaseUsecase = resolver.resolve(FirebaseUsecase.self)!
            let dependency = RichTextViewController.Dependency(html: markdown,
                                                               storeVO: storeVO,
                                                               usecase: firebaseUsecase,
                                                               viewType: viewType)
            let vc = RichTextViewController.create(with: dependency)
            return vc
        }
        
        
        // MARK: SideMenu VC
        container.register(SideMenuViewController.self) { resolver in
            let authUsecase = resolver.resolve(AuthUsecase.self)!
            return SideMenuViewController.create(usecase: authUsecase)
        }.inObjectScope(.home)
        
        container.register(HomeViewController.self) { resolver in
            let homeViewModel = resolver.resolve(HomeViewModel.self)!
            _ = resolver.resolve(ContributionViewModel.self)!
            let sideMenuViewController = resolver.resolve(SideMenuViewController.self)!
            
            let dependency = HomeViewController.Dependencies(homeViewModel: homeViewModel,
                                                             sidemenuVC: sideMenuViewController)
            
            return HomeViewController.create(with: dependency)
        }
    }
}


