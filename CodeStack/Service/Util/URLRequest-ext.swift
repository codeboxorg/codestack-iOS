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
                        method: String = "GET") -> URLRequest {
        
        let components = URLComponents(string: url.absoluteString)!
        
        var queryItems: [URLQueryItem] = []
        
        body.forEach{ key, value in
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var request = URLRequest(url: components.url! )
        
        request.httpMethod = method
        
        headers.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        return request
    }
}
