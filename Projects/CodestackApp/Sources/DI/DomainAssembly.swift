//
//  DomainAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Domain

public struct DomainAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(AuthUsecase.self) { resolver in
            let authRepo = resolver.resolve(AuthRepository.self)!
            return AuthUsecase(authRepository: authRepo)
        }
        container.register(ProfileUsecase.self) { resolver in
            let web = resolver.resolve(WebRepository.self)!
            let fbRepo = resolver.resolve(FBRepository.self)!
            return ProfileUsecase(dependency: .init(webRepository: web, fbRepository: fbRepo))
        }
        
        container.register(ProblemUsecase.self) { resolver in
            let web = resolver.resolve(WebRepository.self)!
            let db = resolver.resolve(DBRepository.self)!
            
            let dp = ProblemUsecase.Dependency.init(web: web, db: db)
            return ProblemUsecase(dependency: dp)
        }
        
        container.register(HistoryUsecase.self) { resolver in
            let db = resolver.resolve(DBRepository.self)!
            let web = resolver.resolve(WebRepository.self)!
            return DefaultHistoryUsecase.init(webRepository: web, dbRepository: db)
        }
        
        container.register(HomeUsecase.self) { resolver in
            let db = resolver.resolve(DBRepository.self)!
            let web = resolver.resolve(WebRepository.self)!
            return HomeUsecase(webRepository: web, dbRepository: db)
        }
        
        container.register(SubmissionUseCase.self) { resolver in
            let db = resolver.resolve(DBRepository.self)!
            let web = resolver.resolve(WebRepository.self)!
            return DefaultSubmissionUseCase(dbRepository: db,
                                            webRepository: web)
        }.inObjectScope(.container)
        
        container.register(CodestackUsecase.self) { resolver in
            let fbrepository = resolver.resolve(FBRepository.self)!
            return CodestackUsecase(fbRepository: fbrepository)
        }
    }
}


