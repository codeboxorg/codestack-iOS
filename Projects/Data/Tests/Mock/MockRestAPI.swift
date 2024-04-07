//
//  MockRestAPI.swift
//  Data
//
//  Created by 박형환 on 3/19/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
@testable import CSNetwork
import RxSwift
import XCTest


public enum TestToken {
    static let token = "안녕하세요 토큰 입니다"
}


public final class MockRestAPI: RestAPI {
    
    private let mockSession: URLSessionProtocol
    
    public init(mockSession: URLSessionProtocol) {
        self.mockSession = mockSession
    }
    
    public func request<T>(_ endpoint: EndPoint, operation: @escaping CSNetwork.Operation<T>) -> Maybe<T> {
        Maybe<T>.create { maybe in
            if MockKeychain.getTestToken() == TestToken.token {
                maybe(.error(APIError.httpResponseError(code: 401)))
            } else {
                maybe(.error(APIError.decodingError))
            }
            return Disposables.create { }
        }
    }
    
    public func post(_ endpoint: EndPoint) -> Completable {
        Completable.create { maybe in
            if KeychainItem.currentFBIdToken == TestToken.token {
                maybe(.error(APIError.httpResponseError(code: 401)))
            } else {
                maybe(.error(APIError.noneHTTPResponse))
            }
            return Disposables.create { }
        }
    }
    
    public func post(_ endpoint: EndPoint, operation: CSNetwork.Operation<Void>?) -> Completable {
        .never()
    }
    
    public func request<T>(_ api: API, operation: @escaping CSNetwork.Operation<T>) -> Maybe<T> {
        .empty()
    }
    
    public func request<T>(_ request: URLRequest, operation: @escaping CSNetwork.Operation<T>) -> Maybe<T> {
        .empty()
    }
    
    public func reissueToken(token: RefreshToken) -> Observable<(response: HTTPURLResponse, data: Data)> {
        .empty()
    }
    
}
