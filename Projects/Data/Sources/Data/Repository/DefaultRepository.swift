//
//  ApolloService.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/25.
//

import Foundation
import RxSwift
import CodestackAPI
import Apollo
import Global
import Domain
import CSNetwork

public class DefaultRepository: WebRepository {
    
    private var tokenAcquizition: TokenAcquisitionService<RefreshToken>
    private var graphAPI: GraphQLAPI
    private var restAPI: RestAPI
    
    public struct Dependency {
        public var tokenAcquizition: TokenAcquisitionService<RefreshToken>
        public var graphAPI: GraphQLAPI
        public var restAPI: RestAPI
        
        public init(tokenAcquizition: TokenAcquisitionService<RefreshToken>, graphAPI: GraphQLAPI, restAPI: RestAPI) {
            self.tokenAcquizition = tokenAcquizition
            self.graphAPI = graphAPI
            self.restAPI = restAPI
        }
    }
    
    public init(dependency: Dependency) {
        self.tokenAcquizition = dependency.tokenAcquizition
        self.graphAPI = dependency.graphAPI
        self.restAPI = dependency.restAPI
    }
    
    public func signUp(member: MemberVO) -> Maybe<Bool> {
        let dto = MemberDTO(id: "id",
                            password: "pwd",
                            email: member.email,
                            nickName: member.nickName,
                            language: LanguageVO.default.name)
        
        return restAPI.request(.rest(.regitster(dto))) { data in
            return true
        }
        .map { $0 }
        .retry(when: { [weak self] errorObservable in
            guard let self else { return Observable<Void>.never() }
            return errorObservable.renewToken(with: self.tokenAcquizition)
        })
    }
    
    public func passwordChange(_ original: Pwd, new: Pwd) -> Maybe<Bool> {
        restAPI.request(.rest(.password(original, new))) { _ in
            return true
        }
        .map { $0 }
        .retry(when: { [weak self] errorObservable in
            guard let self else { return Observable<Void>.never() }
            return errorObservable.renewToken(with: self.tokenAcquizition)
        })
    }
    
    public func editProfile(_ image: Data) -> Maybe<ImageURL> {
        restAPI.request(.rest(.profile(image))) { data in
            String(data: data, encoding: .utf8)
        }
        .map { $0 }
        .retry(when: { [weak self] errorObservable in
            guard let self else { return Observable<Void>.never() }
            return errorObservable.renewToken(with: self.tokenAcquizition)
        })
    }
    
    public func getMemberVO() -> MemberVO {
        UserManager.shared.profile
    }
    
    public func updateEmail(_ email: String) {
        UserManager.email = email
    }
    
    public func updateMember(_ nickName: String) {
        UserManager.nickName = nickName
    }
    
    public func getSolvedProblems(_ username: String) -> Maybe<[ProblemIdentityVO]>  {
        let query = API.GRAPH_QUERY(path: .SOLVE_PR_LIST(username: username)) as! FetchSolvedProblemQuery
        return graphAPI.fetch(query: query , cachePolicy: .default, queue: .main)
            .map { item in
                item.matchMember
                    .solvedProblems
                    .map { $0.fragments.problemIdentityFR.toDomain() }
            }
    }
    
    public func getMe() -> Maybe<MemberVO> {
        let query = API.GRAPH_QUERY(path: .ME) as! FetchMeQuery
        return graphAPI.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, queue: .main)
            .timeout(.milliseconds(400), scheduler: MainScheduler.instance)
            .map { item in
                item.getMe.fragments.memberFR.toDomain()
            }
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.tokenAcquizition)
            })
    }
    
    public func updateNickName(_ nickname: String) -> Maybe<MemberVO> {
        let mutation = API.GRAPH_MUTATION(path: .UPDATE_NICKNAME(nickname: nickname)) as! UpdateNickNameMutation
        return graphAPI.perform(query: mutation, cachePolichy: .default, queue: .global(qos: .default))
            .map { item in
                item.updateNickname.fragments.memberFR.toDomain()
            }
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.tokenAcquizition)
            })
    }
    
    public func mapError(_ error: Error) -> Error? {
        if let error = error as? TokenAcquisitionError {
            return error.toDomain()
        } else if let error = error as? SendError {
            return error
        }
        return error
    }
}

/// Graph Mutation Parameter
public struct GRMutation {
    public let languageId: String
    public let problemId: String
    public let sourceCode: String
    
    public init(languageId: String, problemId: String, sourceCode: String) {
        self.languageId = languageId
        self.problemId = problemId
        self.sourceCode = sourceCode
    }
}
