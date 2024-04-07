//
//  MockURLSession.swift
//  Data
//
//  Created by 박형환 on 4/24/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
@testable import CSNetwork

public final class MockURLSession: URLSessionProtocol {
    private let response: (data: Data?, response: URLResponse?, error: (any Error)?)
    
    public init(response: (data: Data?, response: URLResponse?, error: (any Error)?)) {
        self.response = response
    }
    
    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        MockURLSessionDataTask {
            completionHandler(self.response.data,
                              self.response.response,
                              self.response.error)
        }
    }
}

public final class MockURLSessionDataTask: URLSessionDataTask {
    private let completionHandler: () -> Void
    
    public init(completionHandler: @escaping () -> Void) {
        self.completionHandler = completionHandler
    }
    
    override public func resume() {
        completionHandler()
    }
}
