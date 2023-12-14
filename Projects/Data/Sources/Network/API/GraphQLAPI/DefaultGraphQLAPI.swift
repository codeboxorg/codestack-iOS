//
//  Client.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/23.
//

import Foundation
import Apollo
import RxSwift
import CodestackAPI


public final class DefaultGraphQLAPI {
    
    public struct Dependency {
        var baseURL: URL
        let configuration: URLSessionConfiguration
        
        public init(baseURL: URL,
                    configuration: URLSessionConfiguration) {
            self.baseURL = baseURL
            self.configuration = configuration
        }
    }
    
    private let client: ApolloClient
    
    private var disposeBag = DisposeBag()
    
    private let store = ApolloStore(cache: InMemoryNormalizedCache())
    
    private init(base url: URL, session client: URLSessionClient) {
        self.client = ApolloClient(
            networkTransport: RequestChainNetworkTransport(
                interceptorProvider: NetworkInterceptorProvider(
                    client: client,
                    shouldInvalidateClientOnDeinit: true,
                    store: store
                ),
                endpointURL: url
            ),
            store: store
        )
    }

    public convenience init(dependency: Dependency) {
        let sessionClient = URLSessionClient(
            sessionConfiguration: dependency.configuration,
            callbackQueue: .main
        )
        
        self.init(base: dependency.baseURL,session: sessionClient)
    }
}


//MARK: - ApolloRepository Extension
extension DefaultGraphQLAPI: GraphQLAPI {
    public func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .default,
        queue: DispatchQueue = DispatchQueue.main) -> Maybe<Query.Data>
    {
        return self.client.rx
            .fetch(query: query,
                   cachePolicy: cachePolicy,
                   queue: queue)
    }
    
    
    public func perform<Query: GraphQLMutation>(
        query: Query,
        cachePolichy: CachePolicy = .default,
        queue: DispatchQueue = DispatchQueue.main) -> Maybe<Query.Data>
    {
        return self.client.rx.perform(mutation: query, queue: queue)
    }
}
