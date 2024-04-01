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
    
    public func requestLogin(name id: String, password: String) -> Observable<MemberVO> {
        authRepository
            .request(name: id, password: password).asObservable()
            .withUnretained(self)
            .do(onNext: { usecase, tokenVO in usecase.authRepository.saveToken(token: tokenVO) })
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .flatMap { usecase, _ in usecase.authRepository.getMe() }
    }
    
    
    public func firebaseAuth(email: String, pwd: String) -> Observable<MemberVO> {
        authRepository
            .firebaseAuth(email: email, pwd: pwd)
            .asObservable()
            .withUnretained(self)
            .flatMap {  usecase, info in
                usecase.authRepository
                    .firebaseToeknSave(token: info.fbTokenVO)
                    .andThen(Observable.just(info.toVO()))
            }
            .withUnretained(self)
            .flatMap { usecase, info -> Observable<(MemberVO)> in
                usecase.fetchfirebaseStoreUserInfo()
                    .map { nicknameVO in
                        var memberVO = info
                        memberVO.nickName = nicknameVO.nickname // TODO: Image 처리
                        memberVO.preferLanguage = (LanguageVO.languageMap[nicknameVO.preferLanguage] ?? .default)
                        memberVO.profileImage = nicknameVO.profileImagePath
                        return (memberVO)
                    }.do(onNext: { usecase.saveMember(member: $0) })
            }
    }
    
    public func firebaseAnonymousAuth() -> Observable<Void> {
        authRepository
            .firebaseAnonymousAuth()
            .asObservable()
    }
    
    public func firebaseRegister(_ query: RegisterQuery) -> Observable<MemberVO> {
        authRepository
            .firebaseRegister(query)
            .asObservable()
            .withUnretained(self)
            .flatMap { usecase, info in
                let idToken = info.fbTokenVO.idToken
                let uid = info.fbTokenVO.localId
                let nickname = query.nickname
                
                return usecase.authRepository
                    .firebaseStoreUserInfoSave(token: idToken, uid: uid, nickname: nickname)
                    .andThen(Observable.just(info))
                    .asObservable()
            }
            .withUnretained(self)
            .flatMap { usecase, info in
                let memberVO = info.toVO()
                usecase.saveMember(member: memberVO)
                return usecase.authRepository
                    .firebaseToeknSave(token: info.fbTokenVO)
                    .andThen(Observable.just(memberVO))
            }
    }
    
    public func firebaseLogout() throws {
        try authRepository.firebaseLogout()
    }
    
    public func fetchfirebaseStoreUserInfo() -> Observable<FBUserNicknameVO> {
        authRepository.fetchfirebaseStoreUserInfo()
    }
    
    public func firebaseTokenReissue() -> Completable {
        authRepository.firebaseReissueToken()
    }
    
    public func saveMember(member: MemberVO) {
        authRepository.saveMember(member: member)
    }
    
    public func saveToken(token: CSTokenVO) {
        authRepository.saveToken(token: token)
    }
    
    public func request(name id: String, password: String) -> Observable<CSTokenVO> {
        authRepository.request(name: id, password: password).asObservable()
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
}
