//
//  URLRequest-ext.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation


extension URLRequest{
    static func request(url: URL,
                        headers: [String: String] = [:],
                        body: [String : String] = [:],
                        method: String) -> URLRequest {
        
        var request = URLRequest(url: url )
        
        request.httpMethod = method
        
        headers.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body,
                                                             options: [])
        }catch{
            fatalError("postHeader(with token: GitToken) -> URLRequest: \(error)")
        }
        
        return request
    }
}
