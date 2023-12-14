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
    
    func getSolvedProblems(_ query: FetchSolvedProblemQuery) -> Maybe<[ProblemIdentityFR]>
    
    func getMe(_ graph: GRAPH) -> Maybe<MemberFR>
    func updateNickName(_ graph: GRAPH) -> Maybe<MemberFR>
    func perform(_ graph: GRAPH, max retry: Int) -> Maybe<SubmissionFR>
    func getProblemsQuery(_ graph: GRAPH) -> Maybe<([ProblemFR],PageInfoFR)>
    func getProblemByID(_ graph: GRAPH) -> Maybe<ProblemFR>
    func getAllTag(_ graph: GRAPH) -> Maybe<([TagFR],PageInfoFR)>
    func getAllLanguage(_ graph: GRAPH) -> Maybe<[LanguageFR]>
    func getMeSubmissions(_ graph: GRAPH) -> Maybe<[SubmissionFR]>
    func getSubmission(_ graph: GRAPH, cache: CachePolicy?) -> Maybe<([SubmissionFR],PageInfoFR)>
    
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
