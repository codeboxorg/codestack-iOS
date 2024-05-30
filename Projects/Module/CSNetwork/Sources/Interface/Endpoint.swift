//
//  Endpoint.swift
//  Network
//
//  Created by 박형환 on 1/17/24.

//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public protocol EndPoint {
    var host: String { get }
    var scheme: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var header: [String: String] { get set }
    var body: Data? { get set }
    var queryParams: [String: String]? { get } // Added for query parameters
    var port: Int? { get }
}

public extension EndPoint {
    
    var port: Int? {
        nil
    }
    
    var scheme: String {
        return "https"
    }
    var host: String {
        return ""
    }
    
    @discardableResult
    mutating func setToken(_ token: String) -> Self {
        self.header["Authorization"] = "Bearer \(token)"
        return self
    }
    
    @discardableResult
    mutating func setBody(_ body: Data) -> Self {
        self.body = body
        return self
    }
    
    func createURLRequest() throws -> URLRequest {
        var urlString = "https://" + "\(self.host)" + "\(self.path)"
        self.queryParams?.forEach { key, value in
            urlString += "?\(key)=\(value)"
        }
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = self.method.rv
        request.allHTTPHeaderFields = self.header
        
        if let body = self.body {
            request.httpBody = body
        }
        return request
    }
    
    
    func createRequest() throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = self.scheme
        urlComponents.host = self.host
        urlComponents.path = self.path
        urlComponents.queryItems = []
        urlComponents.port = self.port
        self.queryParams?.forEach { key, value in
            let item = URLQueryItem(name: key, value: value)
            urlComponents.queryItems?.append(item)
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.badURLError
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = self.method.rv
        request.allHTTPHeaderFields = self.header
        if let body = self.body {
            request.httpBody = body
        }
        return request
    }
}
