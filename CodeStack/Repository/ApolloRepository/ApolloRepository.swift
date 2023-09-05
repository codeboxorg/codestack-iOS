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
    
    private var tokenService: TokenAcquisitionService<CodestackResponseToken>?
    
    private let client: ApolloClient
    
    private let baseURL = GraphAPI.baseURL
    
    private var accessToken: String = KeychainItem.currentAccessToken
    
    private var disposeBag = DisposeBag()
    
    private init() {
        let configuration: URLSessionConfiguration = .default
        
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(accessToken)"]
        
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
    
    convenience init(dependency: TokenAcquisitionService<CodestackResponseToken>){
        
        self.init()
        self.tokenService = dependency
        
        tokenService?.token
            .subscribe(onNext: { result in
                switch result{
                case .success(let token):
                    Log.debug("token : \(token)")
                case .failure(let error):
                    Log.error("failure: \(error)")
                }
            },onError: { error in
                Log.error("Repository error: \(error)")
            },onDisposed: {
                Log.error("disposed")
            }).disposed(by: disposeBag)
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
        Observable.deferred{ [weak self] in
            guard
                let self,
                let service = self.tokenService
            else { throw TokenAcquisitionError.undefined }
            return service.token.take(1)
        }
        .flatMap{ value in
            Log.debug("ㅣ\(value)")
            return self.client.rx.perform(mutation: query, queue: queue)
        }.asMaybe()
    }
}
