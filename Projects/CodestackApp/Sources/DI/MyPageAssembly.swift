//
//  MypageAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Foundation
import Domain

public struct MyPageAssembly: Assembly {
    
    public func assemble(container: Container) {
        container.register(EditProfileViewModel.self) { resolver, memberVO, data in
            let useCase = resolver.resolve(ProfileUsecase.self)!
            let dp = EditProfileViewModel.Dependency(profileUsecase: useCase, initState: memberVO, profileImage: data)
            return EditProfileViewModel.create(with: dp)
        }
        
        container.register(MyPageViewModel.self) { resolver in
            let useCase = resolver.resolve(ProfileUsecase.self)!
            let dp = MyPageViewModel.Dependency(profileUsecase: useCase)
            return MyPageViewModel(dependency: dp)
        }
        
        container.register(EditProfileViewController.self) { resolver, member, data in
            let member: MemberVO = member
            let data: Data = data
            let viewmodel = resolver.resolve(EditProfileViewModel.self, arguments: member, data)!
            return EditProfileViewController.create(with: viewmodel)
        }
        
        container.register(MyPageViewController.self) { resolver in
            let viewModel = resolver.resolve(MyPageViewModel.self)!
            let contriviewModel = resolver.resolve(ContributionViewModel.self)!
            return MyPageViewController.create(with: .init(myPageViewModel: viewModel,
                                                           contiributionViewModel: contriviewModel))
        }
    }
}
