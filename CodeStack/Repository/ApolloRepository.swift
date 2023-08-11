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


final class ApolloRepository {
    
    static var shared: ApolloRepository = ApolloRepository()
    
    private let client: ApolloClient
    
    private let baseURL = GraphAPI.baseURL
    
    private var accessToken: String = KeychainItem.currentAccessToken
    
    private init() {
        let configuration: URLSessionConfiguration = .default
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(accessToken)"]
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let sessionClient = URLSessionClient(
            sessionConfiguration: configuration,
            callbackQueue: .main
        )
        
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        
        self.client = ApolloClient(
            networkTransport: RequestChainNetworkTransport(
                interceptorProvider: DefaultInterceptorProvider(
                    client: sessionClient,
                    shouldInvalidateClientOnDeinit: true,
                    store: store
                ),
                endpointURL: baseURL
            ),
            store: store
        )
    }
}

extension ApolloRepository: Repository{
    func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .default,
        queue: DispatchQueue = DispatchQueue.main) -> Maybe<Query.Data>
    {
        return self.client.rx
            .fetch(query: query,
                   cachePolicy: cachePolicy,
                   queue: queue)
    }
    
    
    func perform<Query: GraphQLMutation>(
        query: Query,
        cachePolichy: CachePolicy = .default,
        queue: DispatchQueue = DispatchQueue.main) -> Maybe<Query.Data>
    {
        return self.client.rx.perform(mutation: query, queue: queue)
    }
}

