//
//  DataAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Data
import Domain
import CSNetwork

public struct DataAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(AuthRepository.self) { resolver in
            let auth = resolver.resolve(Auth.self)!
            let graph = resolver.resolve(GraphQLAPI.self)!
            let rest = resolver.resolve(RestAPI.self)!
            return DefaultAuthRepository(auth: auth, graph: graph, rest: rest)
        }.inObjectScope(.container)
        
        container.register(TrackService.self) { resolver in
            let auth = resolver.resolve(AuthRepository.self)!
            let tokenReissue = auth.firebaseReissueToken
            return TrackService.init(tokenReissue)
        }
        
        container.register(TokenAcquisitionService<RefreshToken>.self) { resolver in
            let service = resolver.resolve(RestAPI.self)!
            let defaultService = service as! DefaultRestAPI
            return TokenAcquisitionService(initialToken: defaultService.initialToken,
                                           getToken: defaultService.reissueToken(token:),
                                           max: 2,
                                           extractToken: API.extractAccessToken)
        }.inObjectScope(.container)
               
        
        container.register(WebRepository.self) { resolver in
            let graphAPI = resolver.resolve(GraphQLAPI.self)!
            let restAPI = resolver.resolve(RestAPI.self)!
            let token = resolver.resolve(TokenAcquisitionService<RefreshToken>.self)!
            return DefaultRepository(dependency: .init(tokenAcquizition: token,
                                                       graphAPI: graphAPI,
                                                       restAPI: restAPI))
        }.inObjectScope(.container)
        
        
        container.register(DBRepository.self) { resolver in
            let coreDataStack = CoreDataStack(bundle: DataResources.bundle, version: 1)
            return DefaultDBRepository(persistenStore: coreDataStack)
        }.inObjectScope(.container)
        
        
        container.register(FBRepository.self) { resolver in
            let restAPi = resolver.resolve(RestAPI.self)!
            let tokenService = resolver.resolve(TrackService.self)!
            
            return DefaultFBRepository(rest: restAPi, trackTokenService: tokenService)
        }.inObjectScope(.container)
        
        
        container.register(JZSubmissionRepository.self) { resolver in
            let restAPi = resolver.resolve(RestAPI.self)!
            return DefaultJZSubmissionRepository(rest: restAPi)
        }
        
        container.register(SubmissionRepository.self) { resolver in
            let graphAPI = resolver.resolve(GraphQLAPI.self)!
            let restAPI = resolver.resolve(RestAPI.self)!
            let tokenService = resolver.resolve(TokenAcquisitionService<RefreshToken>.self)!
            
            return DefaultSubmissionRepository(tokenAcquizition: tokenService,
                                               graphAPI: graphAPI,
                                               restAPI: restAPI)
        }.inObjectScope(.container)
        
        container.register(PostingRepository.self) { resolver in
            let restAPi = resolver.resolve(RestAPI.self)!
            let tokenService = resolver.resolve(TrackService.self)!
            
            return DefaultPostingRepository(rest: restAPi, trackTokenService: tokenService)
        }.inObjectScope(.container)
    }
}
