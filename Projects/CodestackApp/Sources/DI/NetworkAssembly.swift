//
//  NetworkDependency.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Foundation
import Data
import Domain
import Global
import CSNetwork

public struct NetworkAssembly: Assembly {
    
    public func assemble(container: Container) {    
        container.register(RestAPI.self) { resolver in
            DefaultRestAPI(session: URLSession(configuration: .default))
        }.inObjectScope(.container)
        
        container.register(Auth.self) { resolver in
            LoginService()
        }.inObjectScope(.container)
        
        container.register(TokenAcquisitionService<RefreshToken>.self) { resolver in
            let service = resolver.resolve(RestAPI.self)!
            let defaultService = service as! DefaultRestAPI
            return TokenAcquisitionService(initialToken: defaultService.initialToken,
                                           getToken: defaultService.reissueToken(token:),
                                           max: 2,
                                           extractToken: API.extractAccessToken)
        }.inObjectScope(.container)
        
        
        container.register(GraphQLAPI.self) { resolver in
            let graphAPIDependency = DefaultGraphQLAPI.Dependency.init(baseURL: DefaultRepository.baseURL,
                                                                       configuration: .default)
            return DefaultGraphQLAPI(dependency: graphAPIDependency)
        }
        
        container.register(AppleLoginManager.self) { resolver in
            let service = resolver.resolve(Auth.self)!
            return AppleLoginManager(serviceManager: service)
        }
    }
}
