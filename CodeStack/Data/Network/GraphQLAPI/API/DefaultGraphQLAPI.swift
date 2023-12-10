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


final class DefaultGraphQLAPI {
    
    struct Dependency {
        var tokenService: TokenAcquisitionService<ReissueAccessToken>
        var baseURL: URL
    }
    
    private var tokenService: TokenAcquisitionService<ReissueAccessToken>?
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

    convenience init(dependency: Dependency) {
        
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
