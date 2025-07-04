//
//  RxApollo.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/23.
//

import Foundation
import RxSwift
//import Apollo
//import CodestackAPI
import Global

public enum ApolloError: Error {
    case gqlErrors([GraphQLError])
}

extension ApolloClient: ReactiveCompatible { }

extension Reactive where Base: ApolloClientProtocol {
    
    /**
     Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.
     
     - parameter query: The query to fetch.
     - parameter cachePolicy: A cache policy that specifies whether results should be fetched from the server or loaded from the local cache
     - parameter context: [optional] A context to use for the cache to work with results. Should default to nil.
     - parameter queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
     
     - returns: A generic observable of fetched query data
     */
    public func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .default,
        contextIdentifier: UUID? = nil,
        queue: DispatchQueue = DispatchQueue.main) -> Maybe<Query.Data>
    {
        return Maybe.create { [weak base] observer in
            let cancellable = base?.fetch(
                query: query,
                cachePolicy: cachePolicy,
                contextIdentifier: contextIdentifier,
                context: nil,
                queue: queue,
                resultHandler: { result in
                    switch result {
                    case let .success(gqlResult):
                        if let errors = gqlResult.errors {
                            observer(.error(ApolloError.gqlErrors(errors)))
                        } else if let data = gqlResult.data {
                            observer(.success(data))
                        } else {
                            observer(.completed)
                        }
                    case let .failure(error):
                        observer(.error(error))
                    }
                }
            )
            return Disposables.create {
                cancellable?.cancel()
            }
        }
    }
    
    /**
     Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
     
     - parameter query: The query to watch.
     - parameter cachePolicy: A cache policy that specifies whether results should be fetched from the server or loaded from the local cache
     - parameter queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
     
     - returns: A generic observable of watched query data
     */
    public func watch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .default,
        callbackQueue: DispatchQueue = DispatchQueue.main) -> Observable<Query.Data>
    {
        return Observable.create { [weak base] observer in
            let watcher = base?.watch(
                query: query,
                cachePolicy: cachePolicy, 
                context: nil,
                callbackQueue: callbackQueue,
                resultHandler: { result in
                    switch result {
                    case let .success(gqlResult):
                        if let errors = gqlResult.errors {
                            observer.onError(ApolloError.gqlErrors(errors))
                        } else if let data = gqlResult.data {
                            observer.onNext(data)
                        }
                        
                    case let .failure(error):
                        observer.onError(error)
                    }
                }
            )
            return Disposables.create {
                watcher?.cancel()
            }
        }
    }
    
    /**
     Performs a mutation by sending it to the server.
     
     - parameter mutation: The query to fetch.
     - parameter context: [optional] A context to use for the cache to work with results. Should default to nil.
     - parameter queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
     
     - returns: A generic observable of created mutation data
     */
    public func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        publishResultToStore: Bool = true,
        queue: DispatchQueue = DispatchQueue.main) -> Maybe<Mutation.Data>
    {
        return Maybe.create { [weak base] observer in
            let cancellable = base?.perform(
                mutation: mutation,
                publishResultToStore: publishResultToStore,
                context: nil,
                queue: queue,
                resultHandler: { result in
                    switch result {
                    case let .success(gqlResult):
                        if let errors = gqlResult.errors {
                             Log.error(errors)
                             Log.error(" SUCCESS error\(ApolloError.gqlErrors(errors))")
                            observer(.error(ApolloError.gqlErrors(errors)))
                        } else if let data = gqlResult.data {
                             Log.error(" SUCCESS data \(data)")
                            observer(.success(data))
                        } else {
                            observer(.completed)
                        }
                        
                    case let .failure(error):
                         Log.error(" failure: \(error)")
                        observer(.error(error))
                    }
                }
            )
            return Disposables.create {
                cancellable?.cancel()
            }
        }
    }
    
    /**
     Uploads the given files with the given operation.
     
     - parameter operation: The operation to send
     - parameter context: [optional] A context to use for the cache to work with results. Should default to nil.
     - parameter files: An array of `GraphQLFile` objects to send.
     - parameter context: [optional] A context to use for the cache to work with results. Should default to nil.
     - parameter queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
     
     - returns: A generic observable of created operation data
     */
    public func upload<Operation: GraphQLOperation>(
        operation: Operation,
        files: [GraphQLFile],
        queue: DispatchQueue = .main) -> Maybe<Operation.Data>
    {
        return Maybe.create { [weak base] observer in
            let cancellable = base?.upload(
                operation: operation,
                files: files,
                context: nil,
                queue: queue,
                resultHandler: { result in
                    switch result {
                    case let .success(gqlResult):
                        if let errors = gqlResult.errors {
                            observer(.error(ApolloError.gqlErrors(errors)))
                        } else if let data = gqlResult.data {
                            observer(.success(data))
                        } else {
                            observer(.completed)
                        }
                    case let .failure(error):
                        observer(.error(error))
                    }
                }
            )
            return Disposables.create {
                cancellable?.cancel()
            }
        }
    }
    
    /**
     Subscribe to a subscription
     
     - parameter subscription: The subscription to subscribe to.
     - parameter fetchHTTPMethod: The HTTP Method to be used.
     - parameter queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
     
     - returns: A generic observable of subscribed Subscription.Data
     */
    public func subscribe<Subscription: GraphQLSubscription>(
        subscription: Subscription,
        queue: DispatchQueue = .main) -> Observable<Subscription.Data>
    {
        return Observable.create { [weak base] observer in
            let cancellable = base?.subscribe(
                subscription: subscription,
                context: nil,
                queue: queue,
                resultHandler: { result in
                    switch result {
                    case let .success(gqlResult):
                        if let errors = gqlResult.errors {
                            observer.onError(ApolloError.gqlErrors(errors))
                        } else if let data = gqlResult.data {
                            observer.onNext(data)
                        }
                        
                    case let .failure(error):
                        observer.onError(error)
                    }
                }
            )
            return Disposables.create {
                cancellable?.cancel()
            }
        }
    }
}

