//
//  AuthManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/08.
//

import Foundation
import RxSwift
import RxCocoa
import Global



public typealias ImageURL = String
public typealias Operation<T> = (_ data: Data) throws -> T?

public final class DefaultRestAPI {
    
    let urlSession: URLSession
    
    public var tokenService: TokenAcquisitionService<RefreshToken> {
        tokenAcquisionService
    }
    
    public var initialToken = RefreshToken(refresh: KeychainItem.currentRefreshToken)
    
    lazy var tokenAcquisionService: TokenAcquisitionService<RefreshToken>
    = TokenAcquisitionService(initialToken: initialToken,
                              getToken: reissueToken(token:),
                              max: 2,
                              extractToken: API.extractAccessToken)
    
    
    public init(session: URLSession = URLSession(configuration: .default)) {
        self.urlSession = session
    }
    
    public func reissueToken(token: RefreshToken) -> Observable<(response: HTTPURLResponse, data: Data)> {
        let refreshToken = KeychainItem.currentRefreshToken
        
        guard
            let request = try? API.rest(.reissue(RefreshToken(refresh: refreshToken))).urlRequest()
        else {
            return Observable.error(APIError.badURLError)
        }
        return urlSession.rx
            .response(request: request)
    }
}
