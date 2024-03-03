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
    
    public func get<T>(_ endpoint: EndPoint, operation: @escaping Operation<T>) -> Maybe<T> {
        guard let request = try? endpoint.createURLRequest() else { return .error(APIError.badURLError)}
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
    
    public func post(_ endpoint: EndPoint) -> Completable {
        guard let request = try? endpoint.createRequest() else { return .error(APIError.badURLError)}
        return Completable.create { [weak self] complete in
            let dataTask = self?.urlSession.dataTask(with: request) { data, res, error in
                guard let res, let data else {
                    complete(.error(error ?? APIError.unKnown))
                    return
                }

                guard let httpResponse = res as? HTTPURLResponse else {
                    complete(.error(APIError.noneHTTPResponse))
                    return
                }
                
                guard (200..<300) ~= httpResponse.statusCode else {
                    complete(.error(APIError.httpResponseError(code: httpResponse.statusCode)))
                    return
                }
                complete(.completed)
            }
            dataTask?.resume()
            return Disposables.create { dataTask?.cancel() }
        }
    }
    
    public func post(_ endpoint: EndPoint, operation: Operation<Void>?) -> Completable {
        guard let request = try? endpoint.createURLRequest() else { return .error(APIError.badURLError)}
        return Completable.create { [weak self] complete in
            let dataTask = self?.urlSession.dataTask(with: request) { data, res, error in
                guard let res, let data else {
                    complete(.error(error ?? APIError.unKnown))
                    return
                }

                guard let httpResponse = res as? HTTPURLResponse else {
                    complete(.error(APIError.noneHTTPResponse))
                    return
                }
                
                guard (200..<300) ~= httpResponse.statusCode else {
                    complete(.error(APIError.httpResponseError(code: httpResponse.statusCode)))
                    return
                }
                
                try? operation?(data)
                
                complete(.completed)
            }
            dataTask?.resume()
            return Disposables.create { dataTask?.cancel() }
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
