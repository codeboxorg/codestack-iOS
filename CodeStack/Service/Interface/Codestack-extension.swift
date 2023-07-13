//
//  Codestack-extension.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/04.
//

import Foundation



extension CodestackAuthorization{
    
    func postHeader(with token: CodestackToken) -> URLRequest {
        let url = getBaseURL(provider: .email)
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        var body: [String : String]
        
        body = [ "email" : token.id, "password" : token.password]
    
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "content-type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")

        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body,
                                                             options: [.fragmentsAllowed,.prettyPrinted,.withoutEscapingSlashes])
        }catch{
            fatalError("postHeader(with token: GitToken) -> URLRequest: \(error)")
        }
        return urlRequest
        
    }
    
}
