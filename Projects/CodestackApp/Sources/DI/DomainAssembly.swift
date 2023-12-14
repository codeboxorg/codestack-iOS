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
        container.register(SubmissionUseCase.self) { resolver in
            let db = resolver.resolve(DBRepository.self)!
            let web = resolver.resolve(WebRepository.self)!
            return DefaultSubmissionUseCase(dbRepository: db,
                                            webRepository: web)
        }.inObjectScope(.container)
    }
}


