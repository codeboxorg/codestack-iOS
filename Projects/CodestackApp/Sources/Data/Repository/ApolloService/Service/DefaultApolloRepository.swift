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


public typealias SolvedProblems = [GetSolvedProblemQuery.Data.MatchMember.SolvedProblem]

public typealias GetSubmissions = GetSubmissionsQuery.Data.GetSubmissions
public typealias GetMeSubmissions = [GetMeSubmissionsQuery.Data.GetMe.Submission]

public typealias SubmissionProblem = CreateSubmissionMutation.Data.CreateSubmission.Problem
public typealias SubmissionMutation = CreateSubmissionMutation.Data.CreateSubmission

public typealias ProblemContent = GetProblemsQuery.Data.GetProblems.Content
public typealias ProblemPageInfo = GetProblemsQuery.Data.GetProblems.PageInfo

public typealias Member = GetMeQuery.Data.GetMe
public typealias MemberSolvedProblem = GetMeQuery.Data.GetMe.SolvedProblem


class DefaultApolloRepository: WebRepository {
    
    private var tokenAcquizition: TokenAcquisitionService<ReissueAccessToken>
    private var api: GraphQLAPI
    
    
    init(dependency: TokenAcquisitionService<ReissueAccessToken> ) {
        self.tokenAcquizition = dependency
        self.api = DefaultGraphQLAPI(dependency: .init(tokenService: dependency,
                                                       baseURL: DefaultApolloRepository.baseURL))
    }
    
    func getSubmissionDate(query: GetMeSubmissionHistoryQuery) -> Single<SubmissionCalendar> {
        
        // TODO: 현재 GraphQL API에 Submission Result Date 모델을 가져오는 API가 없다.
        #if DEBUG
        Single.create { single in
            let calendars = SubmissionCalendar.generateMockCalendar()
            single(.success(calendars))
            return Disposables.create { }
        }
        #endif
//        api.fetch(query: query,
//                   cachePolicy: .fetchIgnoringCacheData,
//                   queue: .global(qos: .background))
//            .map { value in
//                value.getSubmissions.content?.compactMap { SubmissionCalendar(date: $0.createdAt) } ?? []
//            }
//            .asObservable()
//            .asSingle()
    }
    
    func getSolvedProblems(query: GetSolvedProblemQuery) -> Maybe<SolvedProblems> {
        api.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                data.matchMember.solvedProblems
            }
    }
    
    func getMe(query: GetMeQuery) -> Maybe<User> {
        api.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, queue: .main)
            .map { User(me: $0.getMe) }
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.tokenAcquizition)
            })
    }
    
    func updateNickName(mutation: UpdateNickNameMutation) -> Maybe<UpdateNickNameMutation.Data> {
        api.perform(query: mutation, cachePolichy: .default, queue: .global(qos: .default))
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.tokenAcquizition)
            })
    }
    
    func perform(mutation: CreateSubmissionMutation, max retry: Int = 2) -> Maybe<CreateSubmissionMutation.Data> {
        api.perform(query: mutation, cachePolichy: .default, queue: .main)
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.tokenAcquizition)
            }) // retry
    }
    
    func getProblemsQuery(query: GetProblemsQuery ) -> Maybe<[Problem]> {
        api.fetch(query: query, cachePolicy: .default, queue: .main)
            .compactMap { $0.getProblems.content }
            .map { $0.map { problem in Problem(problem: problem) } }
    }
    
    func getProblemByID(query: GetProblemByIdQuery) -> Maybe<Problem> {
        api.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { problem in
                let problem = problem.getProblemById
                let langueges = problem.languages.map { language in Language(id: language.id,
                                                                             name: language.name,
                                                                             _extension: language.extension)}
                let tags = problem.tags.map { tag in Tag(id: tag.id, name: tag.name) }
                return Problem(id: problem.id,
                               title: problem.title,
                               context: problem.context,
                               maxCpuTime: Int(problem.maxCpuTime) ?? 0,
                               maxMemory: Int(problem.maxMemory) ,
                               submission: problem.submission,
                               accepted: problem.accepted, tags: tags, languages: langueges)
            }
    }
    
    func getAllTag(query: GetAllTagQuery) -> Maybe<[Tag]> {
        //tag: 완전 탐색
        //tag: 4
        //tag: 자료 구조
        api.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { ConvertUtil.converting(tag: $0.getAllTag) }
    }
    
    func getAllLanguage(query: GetAllLanguageQuery) -> Maybe<[Language]> {
        api.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { ConvertUtil.converting(data: $0.getAllLanguage) }
    }
    
    func getMeSubmissions(query: GetMeSubmissionsQuery) -> Maybe<GetMeSubmissions> {
        api.fetch(query: query, cachePolicy: .default, queue: .main)
            .map{ data in return data.getMe.submissions }
    }
    
    func getSubmission(query: GetSubmissionsQuery, cache: CachePolicy? = nil) -> Maybe<[Submission]> {
        api.fetch(query: query, cachePolicy: cache ?? .default, queue: .main)
            .compactMap { $0.getSubmissions.content }
            .map { $0.map { data in Submission(submission: data) } }
    }
}

