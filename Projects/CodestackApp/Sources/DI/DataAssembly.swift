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

public struct DataAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(AuthRepository.self) { resolver in
            let auth = resolver.resolve(Auth.self)!
            let graph = resolver.resolve(GraphQLAPI.self)!
            let rest = resolver.resolve(RestAPI.self)!
            return DefaultAuthRepository(auth: auth, graph: graph, rest: rest)
        }
        
        container.register(WebRepository.self) { resolver in
            let graphAPI = resolver.resolve(GraphQLAPI.self)!
            let restAPI = resolver.resolve(RestAPI.self)!
            let token = resolver.resolve(TokenAcquisitionService<RefreshToken>.self)!
            return DefaultRepository(dependency: .init(tokenAcquizition: token,
                                                       graphAPI: graphAPI,
                                                       restAPI: restAPI))
        }.inObjectScope(.container)
        
        container.register(DBRepository.self) { resolver in
            let coreDataStack = CoreDataStack(version: 1)
            return DefaultDBRepository(persistenStore: coreDataStack)
        }.inObjectScope(.container)
    }
}
