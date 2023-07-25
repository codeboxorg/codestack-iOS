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



final class ApolloAPI{
    
    static var shared = ApolloAPI()
    
    private let client: ApolloClient
    
    private let baseURL = API.baseURL
    
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
}

