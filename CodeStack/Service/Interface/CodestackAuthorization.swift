//
//  CodestackAuthorization.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/04.
//

import Foundation
import RxSwift

protocol CodestackAuthorization: OAuthorization{
    func request(name id: ID,password: Pwd) -> Maybe<CodestackResponseToken>
    
    func reissueToken(token: CodestackResponseToken) -> Observable<(response: HTTPURLResponse, data: Data)>
    
    func signUp(id: ID, password: Pwd) -> Maybe<Bool>
}


typealias RefreshToken = String

extension CodestackAuthorization{
    
    func reissueHeader(with token: RefreshToken) -> URLRequest{
        let endpoint = getBaseURL(path: .reissueToken)
        let url = URL(string: endpoint)!
        return URLRequest.request(url: url,
                                  headers: commonHeader,
                                  body: ["refreshToken" : token],
                                  method: "POST")
    }
    
    
    func postHeader(with token: CodestackToken) -> URLRequest? {
        let endpoint = authEndpoint(provider: .email)
        let url = URL(string: endpoint)!
        return URLRequest.request(url: url,
                                  headers: commonHeader,
                                  body: ["email" : token.id,
                                         "password" : token.password],
                                  method: "POST")
        
    }
}
