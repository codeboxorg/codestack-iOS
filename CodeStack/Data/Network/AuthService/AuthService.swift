//
//  AuthManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/08.
//

import Foundation
import RxSwift
import RxCocoa

protocol AuthServiceType {
    
    var tokenService: TokenAcquisitionService<ReissueAccessToken> { get }
    
    func signUp(member: MemberDTO) -> Maybe<Bool>
    
    func editProfile(_ image: Data) -> Maybe<ImageURL>
    
    func passwordChange(_ original: Pwd, new: Pwd) -> Maybe<Bool>
    
    func reissueToken(token: ReissueAccessToken) -> Observable<(response: HTTPURLResponse, data: Data)>
}

typealias ImageURL = String

final class AuthService {
    
    let urlSession: URLSession
    
    var tokenService: TokenAcquisitionService<ReissueAccessToken> {
        tokenAcquisionService
    }
    
    private var initialToken = ReissueAccessToken(accessToken: KeychainItem.currentAccessToken)
    
    private lazy var tokenAcquisionService: TokenAcquisitionService<ReissueAccessToken>
    = TokenAcquisitionService(initialToken: initialToken,
                              getToken: reissueToken(token:),
                              max: 2,
                              extractToken: API.extractAccessToken)
    
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.urlSession = session
    }
    
    func reissueToken(token: ReissueAccessToken) -> Observable<(response: HTTPURLResponse, data: Data)> {
        let refreshToken = KeychainItem.currentRefreshToken
        
        guard
            let request = try? API.reissue(refreshToken).urlRequest()
        else {
            return Observable.error(APIError.badURLError)
        }
        return urlSession.rx
            .response(request: request)
    }
}


extension AuthService: AuthServiceType {
    func passwordChange(_ original: Pwd, new: Pwd) -> Maybe<Bool> {
        guard
            let request = try? API.password(original, new).urlRequest()
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
    
    
    func editProfile(_ image: Data) -> Maybe<ImageURL> {
        guard
            let request = try? API.profile(image).urlRequest()
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
    func signUp(member: MemberDTO) -> Maybe<Bool> {
        
        guard
            let request = try? API.regitster(member).urlRequest()
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
