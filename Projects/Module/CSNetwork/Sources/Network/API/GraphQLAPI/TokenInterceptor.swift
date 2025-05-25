//
//  TokenInterceptor.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/09.
//

import Foundation
//import Apollo
//import ApolloAPI

final class TokenInterceptor: ApolloInterceptor {
    var id: String = UUID().uuidString
    
   func interceptAsync<Operation: GraphQLOperation>(
     chain: RequestChain,
     request: HTTPRequest<Operation>,
     response: HTTPResponse<Operation>?,
     completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
   ) {
       
       let accessToken = KeychainItem.currentAccessToken
       
       self.addTokenAndProceed(
        accessToken,
         to: request,
         chain: chain,
         response: response,
         completion: completion
       )
   }
   private func addTokenAndProceed<Operation: GraphQLOperation>(
     _ token: Token,
     to request: HTTPRequest<Operation>,
     chain: RequestChain,
     response: HTTPResponse<Operation>?,
     completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>
     ) -> Void) {
       
       request.addHeader(name: "Authorization", value: "Bearer \(token)")
       
       chain.proceedAsync(request: request,
                          response: response,
                          interceptor: self,
                          completion: completion)
   }
 }

