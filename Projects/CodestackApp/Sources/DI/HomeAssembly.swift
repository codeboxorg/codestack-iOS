//
//  HomeDependency.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject

public struct HomeAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        // MARK: Home ViewModel
        container.register(HomeViewModel.self) { resolver in
            let dbRepository = resolver.resolve(DBRepository.self)!
            let webRepository = resolver.resolve(WebRepository.self)!
            let homeViewModel: HomeViewModel.Dependency = .init(repository: dbRepository,
                                                                service: webRepository)
            return HomeViewModel(dependency: homeViewModel)
        }.inObjectScope(.container)
        
        
        // MARK: Contribution ViewModel
        container.register(ContributionViewModel.self) { resolver in
            let dbRepository = resolver.resolve(WebRepository.self)!
            let submissionUseCase = resolver.resolve(SubmissionUseCase.self)!
            
            let dependency = ContributionViewModel.Dependency(service: dbRepository,
                                                              submissionUsecase: submissionUseCase)
            
            return ContributionViewModel.create(depenedency: dependency)
        }
        
        
        // MARK: SideMenu VC
        container.register(SideMenuViewController.self) { resolver in
            SideMenuViewController.create()
        }.inObjectScope(.container)
        
        container.register(HomeViewController.self) { resolver in
            let homeViewModel = resolver.resolve(HomeViewModel.self)!
            let contributionViewModel = resolver.resolve(ContributionViewModel.self)!
            let sideMenuViewController = resolver.resolve(SideMenuViewController.self)!
            
            let dependency = HomeViewController.Dependencies(homeViewModel: homeViewModel,
                                                             contiributionViewModel: contributionViewModel,
                                                             sidemenuVC: sideMenuViewController)
            
            return HomeViewController.create(with: dependency)
        }
    }
}


