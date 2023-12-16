//
//  ApolloServiceType.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/08.
//

import Foundation
import RxSwift
import Apollo

public protocol WebRepository: AnyObject {
    // MARK: GraphQL
    //    func getSolvedProblems(_ graph: GRAPH) -> Maybe<[ProblemIdentityFR]>
    
    //    func request<T>(type: T.Type, graph: GRAPH) -> Maybe<T>
    
    //    func getSolvedProblems(_ query: FetchSolvedProblemQuery) -> Maybe<[ProblemIdentityVO]>
    //    func getMe(_ graph: GRAPH) -> Maybe<MemberVO>
    //    func updateNickName(_ graph: GRAPH) -> Maybe<MemberVO>
    //    func getProblemByID(_ graph: GRAPH) -> Maybe<ProblemVO>
    //    func getAllTag(_ graph: GRAPH) -> Maybe<([TagVO],PageInfoVO)>
    //    func getAllLanguage(_ graph: GRAPH) -> Maybe<[LanguageVO]>
    //    func getMeSubmissions(_ graph: GRAPH) -> Maybe<[SubmissionVO]>
    
    func perform(_ mutation: SubmitMutation, max retry: Int) -> Maybe<SubmissionVO>
    func getProblemsQuery(_ query: GRQuery) -> Maybe<([ProblemVO],PageInfoVO)>
    
    func getSubmission(_ query: GRQuery) -> Maybe<([SubmissionVO],PageInfoVO)>
    
    // MARK: REST
    func signUp(member: MemberVO) -> Maybe<Bool>
    
    /// Password
    func passwordChange(_ original: String, new: String) -> Maybe<Bool>
    func editProfile(_ image: Data) -> Maybe<ImageURL>
    
    
    // MARK: 지금도 사용가능
    func getSolvedProblems(_ username: String) -> Maybe<[ProblemIdentityVO]>
    func getMe() -> Maybe<MemberVO>
    func updateNickName(_ nickname: String) -> Maybe<MemberVO>
    
    func getProblemByID(_ problemID: String) -> Maybe<ProblemVO>
    func getAllTag() -> Maybe<([TagVO],PageInfoVO)>
    func getAllLanguage() -> Maybe<[LanguageVO]>
    
    func getMeSubmissions(_ name: String) -> Maybe<[SubmissionVO]>
}


public extension WebRepository {
    
    private static var endpoint: String {
        return Bundle.main.infoDictionary!["graphql_endpoint"] as! String
    }
    
    static var baseURL: URL {
        return URL(string: endpoint)!
    }
    
}
