//
//  ApolloService.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/25.
//

import Foundation
import RxSwift
import CodestackAPI



protocol ApolloServiceType{
    
    func getAllLanguage(query: GetAllLanguageQuery) -> Maybe<[Language]>
    func getAllTag(query: GetAllTagQuery) -> Maybe<[Tag]>
    func getProblemsQuery(query: GetProblemsQuery ) -> Maybe<[Problem]>
    func getSubmission(query: GetSubmissionsQuery) -> Maybe<[Submission]>
    
    func getMe(query: GetMeQuery) -> Maybe<User>
    func getSolvedProblems(query: GetSolvedProblemQuery) -> Maybe<SolvedProblems>
    func getMeSubmissions(query: GetMeSubmissionsQuery) -> Maybe<GetMeSubmissions>
    
    func perform(mutation: CreateSubmissionMutation, max retry: Int) -> Maybe<CreateSubmissionMutation.Data>
}



typealias Token = String

public typealias SolvedProblems = [GetSolvedProblemQuery.Data.MatchMember.SolvedProblem]

public typealias GetSubmissions = GetSubmissionsQuery.Data.GetSubmissions
public typealias GetMeSubmissions = [GetMeSubmissionsQuery.Data.GetMe.Submission]

public typealias SubmissionProblem = CreateSubmissionMutation.Data.CreateSubmission.Problem
public typealias SubmissionMutation = CreateSubmissionMutation.Data.CreateSubmission

public typealias ProblemContent = GetProblemsQuery.Data.GetProblems.Content
public typealias ProblemPageInfo = GetProblemsQuery.Data.GetProblems.PageInfo

public typealias Member = GetMeQuery.Data.GetMe
public typealias MemberSolvedProblem = GetMeQuery.Data.GetMe.SolvedProblem

class ApolloService: ApolloServiceType{
    
    private var tokenAcquizition: TokenAcquisitionService<CodestackResponseToken>
    private var repository: Repository
    
    
    init(dependency: TokenAcquisitionService<CodestackResponseToken> ) {
        self.tokenAcquizition = dependency
        self.repository = ApolloRepository(dependency: self.tokenAcquizition)
    }

    
    func getSolvedProblems(query: GetSolvedProblemQuery) -> Maybe<SolvedProblems> {
        repository.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                data.matchMember.solvedProblems
            }
    }
    
    func getMe(query: GetMeQuery) -> Maybe<User> {
        repository.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { User(me: $0.getMe) }
    }
    
    
    func perform(mutation: CreateSubmissionMutation, max retry: Int = 3) -> Maybe<CreateSubmissionMutation.Data> {
        repository.perform(query: mutation, cachePolichy: .default, queue: .main)
            .retry(when: { [unowned self] errorObservable in
                return errorObservable.renewToken(with: self.tokenAcquizition)
            })// retry
    }
    
    func getProblemsQuery(query: GetProblemsQuery ) -> Maybe<[Problem]> {
        repository
            .fetch(query: query, cachePolicy: .default, queue: DispatchQueue.main)
            .compactMap { $0.getProblems.content }
            .map { $0.map { problem in Problem(problem: problem) } }
    }
    
    func getAllTag(query: GetAllTagQuery) -> Maybe<[Tag]> {
        //tag: 완전 탐색
        //tag: 4
        //tag: 자료 구조
        repository
            .fetch(query: query, cachePolicy: .default, queue: DispatchQueue.main)
            .map { ConvertUtil.converting(tag: $0.getAllTag) }
    }
    
    
    func getAllLanguage(query: GetAllLanguageQuery) -> Maybe<[Language]> {
         repository
            .fetch(query: query, cachePolicy: .default, queue: DispatchQueue.main)
            .map { ConvertUtil.converting(data: $0.getAllLanguage) }
    }
    
    func getMeSubmissions(query: GetMeSubmissionsQuery) -> Maybe<GetMeSubmissions> {
        repository
            .fetch(query: query, cachePolicy: .default, queue: .main)
            .map{ data in return data.getMe.submissions }
    }
    
    func getSubmission(query: GetSubmissionsQuery) -> Maybe<[Submission]> {
        repository
            .fetch(query: query, cachePolicy: .default, queue: DispatchQueue.main)
            .compactMap { $0.getSubmissions.content }
            .map { $0.map { data in Submission(submission: data) } }
    }
}

