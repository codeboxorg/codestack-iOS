//
//  NetworkDependency.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject


public struct NetworkAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(<#T##serviceType: Service.Type##Service.Type#>, factory: <#T##(Resolver) -> Service#>)
    }
}
