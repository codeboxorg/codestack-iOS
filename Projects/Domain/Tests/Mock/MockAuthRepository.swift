//
//  MockAuthRepository.swift
//  Domain
//
//  Created by 박형환 on 2/26/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift
@testable import Domain

public final class MockAuthRepository: AuthRepository {
    public func saveToken(token: CSTokenVO) {
        
    }
    
    public func saveMember(member: MemberVO) {
        
    }
    
    public func getMe() -> RxSwift.Maybe<MemberVO> {
        .never()
    }
    
    public func gitOAuthrization() throws {
        
    }
    
    public func gitOAuthComplete(code: String) {
        
    }
    
    public func request(git serverCode: String) -> RxSwift.Maybe<GitTokenVO> {
        .never()
    }
    
    public func request(with code: String) -> RxSwift.Maybe<CSTokenVO> {
        .never()
    }
    
    public func request(apple code: String, user: String) -> RxSwift.Maybe<CSTokenVO> {
        .never()
    }
    
    public func oAuthComplte(apple code: String, user: String) {
        
    }
    
    public func request(name id: String, password: String) -> RxSwift.Maybe<CSTokenVO> {
        .never()
    }
    
    public func signUp(query: RegisterQuery) -> RxSwift.Maybe<Bool> {
        .never()
    }
    
    public func firebaseStoreUserInfoSave(token: String, uid: String, nickname: String) -> RxSwift.Completable {
        .never()
    }
    
    public func fetchfirebaseStoreUserInfo() -> RxSwift.Observable<FBUserNicknameVO> {
        .never()
    }
    
    public func firebaseRegister(_ query: RegisterQuery) -> RxSwift.Maybe<FBUserInfoVO> {
        .never()
    }
    
    public func firebaseReissueToken() -> RxSwift.Completable {
        .never()
    }
    
    public func firebaseAnonymousAuth() -> RxSwift.Maybe<Void> {
        .never()
    }
    
    public func firebaseAuth(email: String, pwd: String) -> RxSwift.Maybe<FBUserInfoVO> {
        .never()
    }
    
    public func firebaseToeknSave(token: FBTokenVO) -> RxSwift.Completable {
        .never()
    }
    
    public func firebaseLogout() throws {
        
    }
    
    
}

