//
//  AuthRepository.swift
//  Domain
//
//  Created by 박형환 on 12/15/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift

//public protocol GitAuth: AnyObject {
//    func gitOAuthrization() throws
//    func gitOAuthComplete(code: String)
//    
//    func request(git serverCode: String) -> Maybe<GitTokenDTO>
//    func request(with code: GitCode) -> Maybe<CSTokenDTO>
//}
//
//public protocol AppleAuth: AnyObject{
//    func request(with token: AppleDTO) -> Maybe<CSTokenDTO>
//    func oAuthComplte(token: AppleDTO)
//}
//
//public protocol CSAuth {
//    func request(name id: ID,password: Pwd) -> Maybe<CSTokenDTO>
//}

public protocol AuthRepository {
    func getMe() -> Maybe<MemberVO> 
    func gitOAuthrization() throws
    func gitOAuthComplete(code: String)
    func request(git serverCode: String) -> Maybe<GitTokenVO>
    func request(with code: String) -> Maybe<CSTokenVO>
    func request(apple code: String, user: String) -> Maybe<CSTokenVO>
    func oAuthComplte(apple code: String, user: String)
    func request(name id: String, password: String) -> Maybe<CSTokenVO>
    
    func signUp(query: RegisterQuery) -> Maybe<Bool>
}

public struct GitTokenVO {
    public let accessToken: String
    public let scope: String
    public let tokenType: String
    
    public init(accessToken: String, scope: String, tokenType: String) {
        self.accessToken = accessToken
        self.scope = scope
        self.tokenType = tokenType
    }
}

public struct CSTokenVO {
    public let refreshToken: String
    public let accessToken: String
    public let expiresIn: TimeInterval
    public let tokenType: String
    
    public init(refreshToken: String, accessToken: String, expiresIn: TimeInterval, tokenType: String) {
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
    }
}
