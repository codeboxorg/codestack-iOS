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
    
    public func request<T>(_ api: API, operation: @escaping Operation<T>) -> Maybe<T> {
        guard let request = try? api.urlRequest() else { return .error(APIError.badURLError) }
        
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            
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
    
    
    public func passwordChange(_ original: Pwd, new: Pwd) -> Maybe<Bool> {
        guard
            let request = try? API.rest(.password(original, new)).urlRequest()
        else {
            return Maybe.error(APIError.badURLError)
        }
        
        return urlSession.rx
            .response(request: request)
            .asMaybe()
            .map { (response: HTTPURLResponse, data: Data) throws -> Bool in
                guard
                    (200..<300) ~= response.statusCode
                else {
                    throw APIError.httpResponseError(code: response.statusCode)
                }
                return true
            }.retry(when: { [unowned self] errorObservable in
                Log.error("errorObservable: \(errorObservable)")
                return errorObservable.renewToken(with: self.tokenAcquisionService)
            })
    }
    
    
    public func editProfile(_ image: Data) -> Maybe<ImageURL> {
        guard
            let request = try? API.rest(.profile(image)).urlRequest()
        else {
            return Maybe.error(APIError.badURLError)
        }
        
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .map { (response: HTTPURLResponse, data: Data) throws -> ImageURL in
                guard
                    (200..<300) ~= response.statusCode
                else {
                    throw APIError.httpResponseError(code: response.statusCode)
                }
                guard
                    let imageString = String(data: data, encoding: .utf8)
                else {
                    throw APIError.decodingError
                }
                return imageString
            }.retry(when: { [unowned self] errorObservable in
                Log.error(" API.profile(image).urlRequest(): \(errorObservable)")
                return errorObservable.renewToken(with: self.tokenAcquisionService)
            })
    }
    
    
    /// 회원가입
    /// - Parameter member: 유저 DTO
    /// - Returns: true 값 OR throw
    public func signUp(member: MemberDTO) -> Maybe<Bool> {
        
        guard
            let request = try? API.rest(.regitster(member)).urlRequest()
        else {
            return Maybe.error(APIError.badURLError)
        }
        
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .map { (response: HTTPURLResponse, data: Data) throws -> Bool in
                guard
                    (200..<300) ~= response.statusCode
                else {
                    throw APIError.httpResponseError(code: response.statusCode)
                }
                Log.debug("response statusCode: \(response.statusCode)")
                return true
            }
    }
}
