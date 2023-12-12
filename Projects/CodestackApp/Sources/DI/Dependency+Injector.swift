//
//  Injector.swift
//  CodestackApp
//
//  Created by 박형환 on 12/11/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Swinject


public protocol DependencyAssemblable {
    func assemble(_ assemblys: [Assembly])
    func register<T>(_ type: T.Type, _ object: T)
    func register<T>(_ type: T.Type, _ object: T, _ key: String)
    func resolve<T>(_ type: T.Type) -> T
    func resolve<T, U>(_ type: T.Type,_ argument: U) -> T
}

public protocol DependencyResolvable {
    func resolve<T>(_ type: T.Type, _ key: String?) -> T
}

public protocol Injectable: DependencyAssemblable, DependencyResolvable { }

public class DefaultInjector: Injectable {
    
    private let container: Container
    
    public init(container: Container) {
        self.container = container
    }
    
    public func assemble(_ assemblys: [Assembly]) {
        assemblys.forEach {
            $0.assemble(container: container)
        }
    }
    
    public func register<T>(_ type: T.Type, _ object: T) {
        container.register(type) { value in
            object
        }
    }
    
    public func register<T>(_ type: T.Type, _ object: T, _ key: String) {
        container.register(type, name: key) { value in
            object
        }
    }
    
    public func resolve<T>(_ type: T.Type, _ key: String?) -> T {
        guard
            let object = container.resolve(type, name: key)
        else {
            fatalError("did not found \(type) Type Object ")
        }
        return object
    }
    
    public func resolve<T>(_ type: T.Type) -> T {
        guard
            let object = container.resolve(type)
        else {
            fatalError("did not found \(type) Type Object ")
        }
        return object
    }
    
    public func resolve<T, U>(_ type: T.Type,_ argument: U) -> T {
        guard
            let object = container.resolve(type, argument: argument)
        else {
            fatalError("did not found \(type) Type Object ")
        }
        return object
    }
}
