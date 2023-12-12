//
//  NetworkDependency.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject
import Foundation

public struct NetworkAssembly: Assembly {
    
    public func assemble(container: Container) {    
        container.register(AuthServiceType.self) { resolver in
            AuthService(session: URLSession(configuration: .default))
        }.inObjectScope(.container)
        
        container.register(OAuthrizationRequest.self) { resolver in
            LoginService()
        }.inObjectScope(.container)
        
        container.register(TokenAcquisitionService<ReissueAccessToken>.self) { resolver in
            let service = resolver.resolve(AuthServiceType.self)!
            return TokenAcquisitionService(initialToken: service.initialToken,
                                           getToken: service.reissueToken(token:),
                                           max: 2,
                                           extractToken: API.extractAccessToken)
        }.inObjectScope(.container)
        
        container.register(AppleLoginManager.self) { resolver in
            let service = resolver.resolve(OAuthrizationRequest.self)!
            return AppleLoginManager(serviceManager: service)
        }
    }
}
