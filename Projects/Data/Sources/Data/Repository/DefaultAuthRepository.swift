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

public final class DefaultAuthRepository: AuthRepository {
    
    
    private let auth: Auth
    private let graph: GraphQLAPI
    
    private let rest: RestAPI
    
    public init(auth: Auth, graph: GraphQLAPI, rest: RestAPI) {
        self.auth = auth
        self.graph = graph
        self.rest = rest
    }
    
    public func signUp(query: RegisterQuery) -> Maybe<Bool> {
        rest.signUp(member: MemberDTO(id: query.id,
                                      password: query.password,
                                      email: query.email,
                                      nickName: query.nickname))
    }
    
    public func getMe() -> Maybe<MemberVO> {
        graph.fetch(query: FetchMeQuery(),
                    cachePolicy: .fetchIgnoringCacheData,
                    queue: .main)
        .map { $0.getMe.fragments.memberFR.toDomain() }
    }
    
    public func gitOAuthComplete(code: String){
//        loginViewModel?.oAuthComplete(code: code)
        auth.gitOAuthComplete(code: code)
    }
//    
//    /// Git Login URL 오픈 -> 사파리
    public func gitOAuthrization() throws {
        try auth.gitOAuthrization()
//        guard let url = makeGitURL() else { throw APIError.badURLError}
//        if UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        }else{
//            throw APIError.canNotOpen
//        }
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
