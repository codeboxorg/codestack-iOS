//
//  Rest + Extension.swift
//  Data
//
//  Created by 박형환 on 12/14/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import Global
import CSNetwork

// https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]

extension DefaultRestAPI: RestAPI {
    public func request<T>(_ endpoint: EndPoint, operation: @escaping Operation<T>) -> Maybe<T> {
        guard let request = try? endpoint.createRequest() else { return .error(APIError.badURLError)}
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(2), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .map { (response: HTTPURLResponse, data: Data) throws -> T in
                guard
                    (200..<300) ~= response.statusCode
                else {
                    throw APIError.httpResponseError(code: response.statusCode)
                }
                
                do {
                    guard let result = try operation(data) else { throw APIError.decodingError }
                    return result
                } catch {
                    throw APIError.decodingError
                }
            }
    }
    
    public func request<T>(_ request: URLRequest, operation: @escaping Operation<T>) -> Maybe<T> {
        urlSession.rx
            .response(request: request)
            .timeout(.seconds(2), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .map { (response: HTTPURLResponse, data: Data) throws -> T in
                guard
                    (200..<300) ~= response.statusCode
                else {
                    throw APIError.httpResponseError(code: response.statusCode)
                }
                
                do {
                    guard let result = try operation(data) else { throw APIError.decodingError }
                    return result
                } catch {
                    throw APIError.decodingError
                }
            }
    }
    
    public func request<T>(_ api: API, operation: @escaping Operation<T>) -> Maybe<T> {
        guard let request = try? api.urlRequest() else { return .error(APIError.badURLError) }
        
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(2), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .map { (response: HTTPURLResponse, data: Data) throws -> T in
                guard
                    (200..<300) ~= response.statusCode
                else {
                    throw APIError.httpResponseError(code: response.statusCode)
                }
                
                do {
                    guard let result = try operation(data) else { throw APIError.decodingError }
                    return result
                } catch {
                    throw APIError.decodingError
                }
            }
    }
}
