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

protocol WebRepository: AnyObject {
    func getSubmissionDate(query: GetMeSubmissionHistoryQuery) -> Single<SubmissionCalendar>
    func getSubmission(query: GetSubmissionsQuery, cache: CachePolicy?) -> Maybe<[Submission]>
    func getMeSubmissions(query: GetMeSubmissionsQuery) -> Maybe<GetMeSubmissions>
    
    func getAllLanguage(query: GetAllLanguageQuery) -> Maybe<[Language]>
    func getAllTag(query: GetAllTagQuery) -> Maybe<[Tag]>
    
    func getProblemsQuery(query: GetProblemsQuery ) -> Maybe<[Problem]>
    func getProblemByID(query: GetProblemByIdQuery) -> Maybe<Problem>
    
    func getMe(query: GetMeQuery) -> Maybe<User>
    func getSolvedProblems(query: GetSolvedProblemQuery) -> Maybe<SolvedProblems>
    
    func perform(mutation: CreateSubmissionMutation, max retry: Int) -> Maybe<CreateSubmissionMutation.Data>
}


extension WebRepository {
    
    private static var endpoint: String {
        return Bundle.main.infoDictionary!["graphql_endpoint"] as! String
    }
    
    static var baseURL: URL {
        return URL(string: endpoint)!
    }
    
}
