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
    func resolve<T, U, Z>(_ type: T.Type,_ arg1: U, _ arg2: Z) -> T
    func resolve<T, U, Z, Q>(_ type: T.Type,_ arg1: U, _ arg2: Z, _ arg3: Q) -> T 
    var container: Container { get }
}

public protocol DependencyResolvable {
    func resolve<T>(_ type: T.Type, _ key: String?) -> T
}

public protocol Injectable: DependencyAssemblable, DependencyResolvable { }

public class DefaultInjector: Injectable {
    
    public let container: Container
    
    public init(container: Container = Container()) {
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
    
    public func resolve<T, U, Z>(_ type: T.Type,_ arg1: U, _ arg2: Z) -> T {
        guard
            let object = container.resolve(type, arguments: arg1, arg2)
        else {
            fatalError("did not found \(type) Type Object ")
        }
        return object
    }
    
    public func resolve<T, U, Z, Q>(_ type: T.Type,_ arg1: U, _ arg2: Z, _ arg3: Q) -> T {
        guard
            let object = container.resolve(type, arguments: arg1, arg2, arg3)
        else {
            fatalError("did not found \(type) Type Object ")
        }
        return object
    }
}
