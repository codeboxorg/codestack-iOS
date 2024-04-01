//
//  AuthRepository.swift
//  Domain
//
//  Created by 박형환 on 12/15/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift

public protocol AuthRepository {
    func saveToken(token: CSTokenVO)
    func saveMember(member: MemberVO)
    func getMe() -> Maybe<MemberVO>
    func gitOAuthrization() throws
    func gitOAuthComplete(code: String)
    func request(git serverCode: String) -> Maybe<GitTokenVO>
    func request(with code: String) -> Maybe<CSTokenVO>
    func request(apple code: String, user: String) -> Maybe<CSTokenVO>
    func oAuthComplte(apple code: String, user: String)
    func request(name id: String, password: String) -> Maybe<CSTokenVO>
    func signUp(query: RegisterQuery) -> Maybe<Bool>
    
    
    /// FireStore에 유저 정보 저장
    /// - Parameters:
    ///   - token: firebase Token
    ///   - uid: user Local ID
    ///   - nickname: nickname
    /// - Returns: 성공여부
    func firebaseStoreUserInfoSave(token: String, uid: String, nickname: String) -> Completable
    
    func fetchfirebaseStoreUserInfo() -> Observable<FBUserNicknameVO>
    
    /// 회원가입 요청
    /// - Parameter query: 회원가입 정ㅇ보
    /// - Returns: User Token 관련 + User 정보
    func firebaseRegister(_ query: RegisterQuery) -> Maybe<FBUserInfoVO>
    
    /// Token 재발행
    /// - Returns: FB token 재발행
    func firebaseReissueToken() -> Completable
    
    /// 익명 로그인
    /// - Returns: 성공여부
    func firebaseAnonymousAuth() -> Maybe<Void>
    
    func firebaseAuth(email: String, pwd: String) -> Maybe<FBUserInfoVO>
    func firebaseToeknSave(token: FBTokenVO) -> Completable
    
    func firebaseLogout() throws
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
