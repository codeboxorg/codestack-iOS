//
//  ApolloServiceType.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/08.
//

import Foundation
import RxSwift
import CodestackAPI
import Apollo
import Data



public protocol WebRepository: AnyObject {
    
    // MARK: GraphQL
//    func getSolvedProblems(_ graph: GRAPH) -> Maybe<[ProblemIdentityFR]>
    
    func request<T>(type: T.Type, graph: GRAPH) -> Maybe<T>
    
    func getSolvedProblems(_ query: FetchSolvedProblemQuery) -> Maybe<[ProblemIdentityVO]>
    
    func getMe(_ graph: GRAPH) -> Maybe<MemberVO>
    func updateNickName(_ graph: GRAPH) -> Maybe<MemberVO>
    func perform(_ graph: GRAPH, max retry: Int) -> Maybe<SubmissionVO>
    func getProblemsQuery(_ graph: GRAPH) -> Maybe<([ProblemVO],PageInfoVO)>
    func getProblemByID(_ graph: GRAPH) -> Maybe<ProblemVO>
    func getAllTag(_ graph: GRAPH) -> Maybe<([TagVO],PageInfoVO)>
    func getAllLanguage(_ graph: GRAPH) -> Maybe<[LanguageVO]>
    func getMeSubmissions(_ graph: GRAPH) -> Maybe<[SubmissionVO]>
    func getSubmission(_ graph: GRAPH, cache: CachePolicy?) -> Maybe<([SubmissionVO],PageInfoVO)>
    
    // MARK: REST
    func signUp(member: MemberDTO) -> Maybe<Bool>
    func passwordChange(_ original: Pwd, new: Pwd) -> Maybe<Bool>
    func editProfile(_ image: Data) -> Maybe<ImageURL>
}


public extension WebRepository {
    
    private static var endpoint: String {
        return Bundle.main.infoDictionary!["graphql_endpoint"] as! String
    }
    
    static var baseURL: URL {
        return URL(string: endpoint)!
    }
    
}
