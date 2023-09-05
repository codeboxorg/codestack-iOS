//
//  AppleAuthorization.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/04.
//

import Foundation
import RxSwift

protocol AppleAuthorization: AnyObject,OAuthorization{
    func request(with token: AppleToken) -> Maybe<CodestackResponseToken>
    
    func oAuthComplte(token: AppleToken)
}


extension AppleAuthorization{
    /// Apple URLRequest
    /// - Parameter token: Apple info
    /// - Returns: URLRequest
    func postHeader(with token: AppleToken) -> URLRequest {
        let url = authEndpoint(provider: .apple)
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        var body: [String : String]
        
        
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "content-type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        
        if let _ = token.user{
            body = [ "code" : token.authorizationCode] //, "user" : user]
        }else{
            body = [ "code" : token.authorizationCode]
        }
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        }catch{
            fatalError("postHeader(with token: GitToken) -> URLRequest: \(error)")
        }
        return urlRequest
        
    }
}
