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
        }.inObjectScope(.container)
        
        container.register(ProfileUsecase.self) { resolver in
            let web = resolver.resolve(WebRepository.self)!
            let fbRepo = resolver.resolve(FBRepository.self)!
            let authRepo = resolver.resolve(AuthRepository.self)!
            return ProfileUsecase(dependency: .init(webRepository: web,
                                                    fbRepository: fbRepo,
                                                    authRepository: authRepo))
        }.inObjectScope(.container)
        
        container.register(ProblemUsecase.self) { resolver in
            let web = resolver.resolve(WebRepository.self)!
            let db = resolver.resolve(DBRepository.self)!
            let submission = resolver.resolve(SubmissionRepository.self)!
            let fb = resolver.resolve(FBRepository.self)!
            let dp = ProblemUsecase.Dependency.init(web: web, db: db, sub: submission, fb: fb)
            return ProblemUsecase(dependency: dp)
        }
        
        container.register(HistoryUsecase.self) { resolver in
            let db = resolver.resolve(DBRepository.self)!
            let web = resolver.resolve(WebRepository.self)!
            let submission = resolver.resolve(SubmissionRepository.self)!
            return DefaultHistoryUsecase.init(webRepository: web, dbRepository: db, submissionRepository: submission)
        }
        
        container.register(HomeUsecase.self) { resolver in
            let db = resolver.resolve(DBRepository.self)!
            let web = resolver.resolve(WebRepository.self)!
            let submission = resolver.resolve(SubmissionRepository.self)!
            return HomeUsecase(webRepository: web, dbRepository: db, submissionRepository: submission)
        }
        
        container.register(SubmissionUseCase.self) { resolver in
            let db = resolver.resolve(DBRepository.self)!
            let web = resolver.resolve(WebRepository.self)!
            let submission = resolver.resolve(SubmissionRepository.self)!
            return DefaultSubmissionUseCase(dbRepository: db,
                                            webRepository: web,
                                            submissionReposiotry: submission)
        }.inObjectScope(.container)
        
        container.register(FirebaseUsecase.self) { resolver in
            let fbrepository = resolver.resolve(FBRepository.self)!
            return FirebaseUsecase(fbRepository: fbrepository)
        }
        
        container.register(JZUsecase.self) { resolver in
            let repo = resolver.resolve(JZSubmissionRepository.self)!
            return JZUsecase(repo: repo)
        }
        
        container.register(CodeUsecase.self) { resolver in
            let dbRepository = resolver.resolve(DBRepository.self)!
            return DefaultCodeUsecase(dbRepository: dbRepository)
        }.inObjectScope(.container)
    }
}


