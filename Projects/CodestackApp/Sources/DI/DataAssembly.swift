//
//  DataAssembly.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Data

public struct DataAssembly: Assembly {
    
    public func assemble(container: Container) {
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
