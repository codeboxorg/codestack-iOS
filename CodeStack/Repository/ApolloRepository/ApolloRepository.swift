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
    
//    static var shared: ApolloRepository = ApolloRepository()
    
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

    convenience init(dependency: Dependency){
        
        let configuration: URLSessionConfiguration = .default
        
        let sessionClient = URLSessionClient(
            sessionConfiguration: configuration,
            callbackQueue: .main
        )

        self.init(base: dependency.baseURL,session: sessionClient)
    }
}


//MARK: - ApolloRepository Extension
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


//let config1 = configuration
//let p1: UnsafeMutableRawPointer = Unmanaged.passUnretained(configuration).toOpaque()
//let p2: UnsafeMutableRawPointer = Unmanaged.passUnretained(config1).toOpaque()
//Log.debug(String(describing: p1))
//Log.debug(String(describing: p2))
//
//let config2 = sessionClient.session.configuration
//let config3 = sessionClient.session.configuration
//
//let copy1_pointer: UnsafeMutableRawPointer = Unmanaged.passUnretained(config1).toOpaque()
//let copy2_Pointer: UnsafeMutableRawPointer = Unmanaged.passUnretained(config2).toOpaque()
//let copy3_Pointer: UnsafeMutableRawPointer = Unmanaged.passUnretained(config3).toOpaque()
//
//Log.debug("copy1_pointer address : \(String(describing: copy1_pointer))")
//Log.debug("copy2_Pointer address : \(String(describing: copy2_Pointer))")
//Log.debug("copy3_Pointer address : \(String(describing: copy3_Pointer))")
//
//Log.debug("header: \(String(describing: sessionClient.session.configuration.httpAdditionalHeaders))")
//
//sessionClient.session.configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(token.accessToken)"]
//
//
//Log.debug("token : \(["Authorization": "Bearer \(token.accessToken)"])")
//
//Log.debug("header: \(String(describing: sessionClient.session.configuration.httpAdditionalHeaders))")
//
////                    let urlConfiguration = URLSessionConfiguration()
////                    urlConfiguration.httpAdditionalHeaders = ["Authorization": "Bearer \(token.accessToken)"]
////                    let urlSessionClient = URLSessionClient(sessionConfiguration: urlConfiguration)
