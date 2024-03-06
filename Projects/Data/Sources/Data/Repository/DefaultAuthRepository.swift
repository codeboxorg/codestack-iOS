//
//  AuthRepository.swift
//  CodestackApp
//
//  Created by 박형환 on 12/15/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import CodestackAPI
import CSNetwork
import FirebaseAuth
import Global

public final class DefaultAuthRepository: AuthRepository {
    
    
    private let auth: CSNetwork.Auth
    private let graph: GraphQLAPI
    private let rest: RestAPI
    
    
    public init(auth: CSNetwork.Auth, graph: GraphQLAPI, rest: RestAPI) {
        self.auth = auth
        self.graph = graph
        self.rest = rest
    }
    
    public func saveToken(token: CSTokenVO) {
        UserManager.shared.saveTokenInfo(with: TokenInfo(expiresIn: token.expiresIn,
                                                         tokenType: token.tokenType))
        KeychainItem.saveTokens(access: token.accessToken, refresh: token.refreshToken)
    }
    
    public func saveMember(member: Domain.MemberVO) {
        UserManager.shared.saveUser(with: member)
    }
    
    public func signUp(query: RegisterQuery) -> Maybe<Bool> {
        let memberDTO = MemberDTO(id: query.id,
                                  password: query.password,
                                  email: query.email,
                                  nickName: query.nickname)
        return rest.request(.rest(.regitster(memberDTO))) { data in
            return true
        }
    }
    
    public func getMe() -> Maybe<MemberVO> {
        graph.fetch(query: FetchMeQuery(),
                    cachePolicy: .fetchIgnoringCacheData,
                    queue: .main)
        .map { $0.getMe.fragments.memberFR.toDomain() }
    }
    
    public func gitOAuthComplete(code: String){
        auth.gitOAuthComplete(code: code)
    }
    
    public func gitOAuthrization() throws {
        try auth.gitOAuthrization()
    }
    
    public func request(git serverCode: String) -> RxSwift.Maybe<Domain.GitTokenVO> {
        auth.request(git: serverCode)
            .map { dto in dto.toDomain() }
    }
    
    public func request(with code: String) -> RxSwift.Maybe<Domain.CSTokenVO> {
        auth.request(with: code)
            .map { $0.toDomain() }
    }
    
    public func request(apple code: String, user: String) -> RxSwift.Maybe<Domain.CSTokenVO> {
        auth
            .request(with: AppleDTO(authorizationCode: code, user: user))
            .map { $0.toDomain() }
    }
    
    public func oAuthComplte(apple code: String, user: String) {
        auth.oAuthComplte(token: AppleDTO(authorizationCode: code, user: user))
    }
    
    public func request(name id: String, password: String) -> RxSwift.Maybe<Domain.CSTokenVO> {
        auth.request(name: id, password: password)
            .map { $0.toDomain() }
    }
}

public typealias FAuth = FirebaseAuth.Auth


public extension DefaultAuthRepository {
    // TODO: 업데이트 이메일 , 프로필, Token 유효성 처리.....
            // 로그인 할때마다 토큰 업데이트
    // TODO: 로그아웃시 유저 nickname 여부
    // TODO: submission VIewModel Graph
    // TODO: Solved Problems 멀 넣지 -> (제출 횟수) (성공) (실패) ()
    // TODO: 인증 처리
    // TODO: FCM
    // TODO: Test
    
    func firebaseReissueToken() -> Completable {
        Completable.create { complete in
            let dispatchItem = DispatchWorkItem {
                FAuth.auth().currentUser?.getIDToken { idToken, error in
                    if let error {
                        let fireErrorCode = AuthErrorCode(_nsError: error as NSError).errorCode
                        guard let authError = AuthFIRError(rawValue: fireErrorCode) else {
                            complete(.error(AuthFIRError.unknown))
                            return
                        }
                        complete(.error(authError))
                    }
                    
                    guard let idToken = idToken else {
                        complete(.error(AuthFIRError.unknown))
                        return
                    }
                    KeychainItem.saveFirebaseIDToken(idToken: idToken)
                    complete(.completed)
                }
            }
            dispatchItem.perform()
            return Disposables.create { dispatchItem.cancel() }
        }
    }
    
    func getFirebaseToken() -> Single<String> {
        Single.create { single in
            let tokenString = KeychainItem.currentFBIdToken
            single(.success(tokenString))
            return Disposables.create { }
        }
    }
    
    // TODO: FireBase
    func firebaseAnonymousAuth() -> Maybe<Void> {
        rest.request(FirebaseAuthEndPoint()) { data in
            return try JSONDecoder().decode(FBTokenVO.self, from: data)
        }.flatMap { [weak self] token in
            guard let self else { return .empty() }
            return self.firebaseToeknSave(token: token).andThen(.just(()))
        }
        .map { $0 }
    }
    
    func firebaseAuth(email: String, pwd: String) -> Maybe<FBUserInfoVO> {
        return Maybe<FBUserInfoVO>.create { maybe in
            let dispatchItem = DispatchWorkItem {
                FAuth.auth().signIn(withEmail: email, password: pwd) { authResult,error  in
                    if let error {
                        let fireErrorCode = AuthErrorCode(_nsError: error as NSError).errorCode
                        guard let authError = AuthFIRError(rawValue: fireErrorCode) else {
                            maybe(.error(AuthFIRError.unknown))
                            return
                        }
                        maybe(.error(authError))
                    }
                    
                    if let authResult {
                        authResult.user.getIDToken { token, err in
                            if err != nil { maybe(.error(AuthFIRError.unknown)); return }
                            guard let idToken = token else {
                                maybe(.error(AuthFIRError.unknown))
                                return
                            }
                            let fbToken = FBTokenVO(kind: "Bearer",
                                                    idToken: idToken,
                                                    refreshToken: authResult.user.refreshToken ?? "",
                                                    localId: authResult.user.uid)
                            let info = FBUserInfoVO(email: authResult.user.email ?? "",
                                                    nickname: "N/A",
                                                    password: pwd,
                                                    fbTokenVO: fbToken)
                            maybe(.success(info))
                        }
                    }
                }
            }
            dispatchItem.perform()
            return Disposables.create { dispatchItem.cancel() }
        }
    }
    
    func firebaseStoreUserInfoSave(token: String, uid: String, nickname: String) -> Completable {
        let query = UserGetQuery(uid: uid, token: token, method: .post)
        let userQuery = UserQuery(nickname: nickname, preferLanguage: "",query: query)
        return rest.post(FireStoreUserPostEndPoint(post: userQuery))
    }
    
    func fetchfirebaseStoreUserInfo() -> Observable<FBUserNicknameVO> {
        let currentUID = KeychainItem.currentFBLocalID
        let idtoken = KeychainItem.currentFBIdToken
        let query = UserGetQuery(uid: currentUID, token: idtoken, method: .get)
        return rest.request(FireStoreUserPostEndPoint(get: query)) { data in
            try JSONDecoder().decode(FBUserDTO.self, from: data)
        }
        .map {$0.toDomain()}
        .asObservable()
    }
    
    func firebaseRegister(_ query: RegisterQuery) -> Maybe<FBUserInfoVO> {
        Maybe<FBUserInfoVO>.create { maybe in
            let dispatchItem = DispatchWorkItem {
                FirebaseAuth.Auth
                    .auth()
                    .createUser(withEmail: query.email,
                                password: query.password) { authResult, error in
                        if let error {
                            let fireErrorCode = AuthErrorCode(_nsError: error as NSError).errorCode
                            guard let authError = AuthFIRError(rawValue: fireErrorCode) else {
                                maybe(.error(AuthFIRError.unknown))
                                return
                            }
                            maybe(.error(authError))
                        }
                        if let authResult {
                            authResult.user.getIDToken { token, err in
                                if err != nil { maybe(.error(AuthFIRError.unknown)); return }
                                guard let idToken = token else {
                                    maybe(.error(AuthFIRError.unknown))
                                    return
                                }
                                let fbToken = FBTokenVO(kind: "Bearer",
                                                        idToken: idToken,
                                                        refreshToken: authResult.user.refreshToken ?? "",
                                                        expiresIn: "",
                                                        localId: authResult.user.uid)
                                
                                let info = FBUserInfoVO(email: authResult.user.email ?? "",
                                                        nickname: query.nickname,
                                                        password: query.password,
                                                        fbTokenVO: fbToken)
                                maybe(.success(info))
                            }
                        }
                }
            }
            dispatchItem.perform()
            return Disposables.create { dispatchItem.cancel() }
        }
    }
    
    func firebaseToeknSave(token: FBTokenVO) -> Completable {
        Completable.create { com in
            do {
                try KeychainItem.saveFirebaseToken(idToken: token.idToken,
                                                   refresh: token.refreshToken,
                                                   localID: token.localId)
                com(.completed)
            } catch {
                com(.error(error))
            }
            return Disposables.create { }
        }
    }
}

extension GitTokenDTO {
    func toDomain() -> GitTokenVO {
        GitTokenVO.init(accessToken: self.accessToken,
                        scope: self.scope,
                        tokenType: self.tokenType)
    }
}

extension CSTokenDTO {
    func toDomain() -> CSTokenVO {
        CSTokenVO(refreshToken: self.refreshToken,
                  accessToken: self.accessToken,
                  expiresIn: self.expiresIn,
                  tokenType: self.tokenType)
    }
}
