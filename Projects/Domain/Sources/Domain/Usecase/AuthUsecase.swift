//
//  AuthUsecase.swift
//  Domain
//
//  Created by 박형환 on 12/15/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift


public final class AuthUsecase {
    private let authRepository: AuthRepository
    
    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    
    public func signUpRequest(query: RegisterQuery) -> Observable<Bool> {
        authRepository.signUp(query: query)
            .asObservable()
    }
    
    public func fetchMe() -> Observable<MemberVO> {
        authRepository.getMe().asObservable()
    }
    
    public func gitOAuthrization() throws {
        try authRepository.gitOAuthrization()
    }
    
    public func gitOAuthComplete(code: String) {
        authRepository.gitOAuthComplete(code: code)
    }
    
    public func request(git serverCode: String) -> Observable<GitTokenVO> {
        authRepository.request(git: serverCode).asObservable()
    }
    
    public func request(with code: String) -> Observable<CSTokenVO> {
        authRepository.request(with: code).asObservable()
    }
    
    public func request(apple code: String, user: String) -> Observable<CSTokenVO> {
        authRepository.request(apple: code, user: user).asObservable()
    }
    
    public func oAuthComplte(apple code: String, user: String) {
        authRepository.oAuthComplte(apple: code, user: user)
    }
    
    public func request(name id: String, password: String) -> Observable<CSTokenVO> {
        authRepository.request(name: id, password: password).asObservable()
    }
}
