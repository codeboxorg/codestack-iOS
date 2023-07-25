//
//  GraphManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/10.
//

import Foundation
import Apollo
import CodestackAPI

class ApolloService{
    
    static let shared: ApolloService = ApolloService()
    
    var record: RecordSet = RecordSet(dictionaryLiteral: ("",[:]),("",[:]),("",[:]))
    
    lazy var store = ApolloStore(cache: InMemoryNormalizedCache(records: record))
    
    lazy var provider = DefaultInterceptorProvider(client: .init(sessionConfiguration: .default,
                                                                 callbackQueue: .current),
                                                   store: store)
    
    var header: [String : String] = [:]

    
    lazy var network = RequestChainNetworkTransport(interceptorProvider: provider,
                                                    endpointURL: URL(string: "https://api-dev.codestack.co.kr/graphql")!,
                                                    additionalHeaders: header)
    
    lazy var client = ApolloClient(networkTransport: network, store: store)
    
    private init(){
        
        
    }
    
    func request(header value: String){
        header = ["Authorization" : "Bearer \(value)"]
        Log.debug(client)
        Log.debug(network.endpointURL)
        Log.debug(network.additionalHeaders)
        
        client.fetch(query: ProblemsQuery(pageNum: .some(1))){ result in
            Log.debug(result)
            switch result {
            case .success(let graphQLResult):
                if let problem = graphQLResult.data?.problems {
                    Log.debug(problem)
                } else if let errors = graphQLResult.errors {
                    // GraphQL errors
                    Log.error(errors)
                }
                Log.error(graphQLResult)
            case .failure(let error):
                // Network or response format errors
                Log.error(error)
            }
        }
    }
}
