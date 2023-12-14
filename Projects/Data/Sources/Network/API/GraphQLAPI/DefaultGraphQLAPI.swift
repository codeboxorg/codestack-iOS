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
        var tokenService: TokenAcquisitionService<RefreshToken>
        var baseURL: URL
        
        public init(tokenService: TokenAcquisitionService<RefreshToken>, baseURL: URL) {
            self.tokenService = tokenService
            self.baseURL = baseURL
        }
    }
    
    private var tokenService: TokenAcquisitionService<RefreshToken>?
    private let client: ApolloClient
    
    private var disposeBag = DisposeBag()
    
    private let store = ApolloStore(cache: InMemoryNormalizedCache())
    
    public init(base url: URL, session client: URLSessionClient) {
    
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
        
        let configuration: URLSessionConfiguration = .default
        
        let sessionClient = URLSessionClient(
            sessionConfiguration: configuration,
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
