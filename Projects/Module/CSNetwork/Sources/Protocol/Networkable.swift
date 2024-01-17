//
//  Networkable.swift
//  Network
//
//  Created by 박형환 on 1/17/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public protocol Networkable {}

public extension Networkable {
    func createRequest(endPoint: EndPoint) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = endPoint.scheme
        urlComponents.host = endPoint.host
        urlComponents.path = endPoint.path
        guard let url = urlComponents.url else {
            return nil
        }
        let encoder = JSONEncoder()
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method.rv
        request.allHTTPHeaderFields = endPoint.header
        if let body = endPoint.body {
            request.httpBody = try? encoder.encode(body)
        }
        return request
    }
}
