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
import Data
import Global

//public typealias SolvedProblems = [GetSolvedProblemQuery.Data.MatchMember.SolvedProblem]
//
//public typealias GetSubmissions = GetSubmissionsQuery.Data.GetSubmissions
//public typealias GetMeSubmissions = [GetMeSubmissionsQuery.Data.GetMe.Submission]
//
//public typealias SubmissionProblem = CreateSubmissionMutation.Data.CreateSubmission.Problem
//public typealias SubmissionMutation = CreateSubmissionMutation.Data.CreateSubmission
//
//public typealias ProblemContent = GetProblemsQuery.Data.GetProblems.Content
//public typealias ProblemPageInfo = GetProblemsQuery.Data.GetProblems.PageInfo
//
//public typealias Member = GetMeQuery.Data.GetMe
//public typealias MemberSolvedProblem = GetMeQuery.Data.GetMe.SolvedProblem


public class DefaultRepository: WebRepository {
    
    private var tokenAcquizition: TokenAcquisitionService<RefreshToken>
    private var graphAPI: GraphQLAPI
    private var restAPI: RestAPI
    
    public struct Dependency {
        var tokenAcquizition: TokenAcquisitionService<RefreshToken>
        var graphAPI: GraphQLAPI
        var restAPI: RestAPI
    }
    
    public init(dependency: Dependency ) {
        self.tokenAcquizition = dependency.tokenAcquizition
        self.graphAPI = dependency.graphAPI
        self.restAPI = dependency.restAPI
    }
    
    func getSubmissionDate(api: GRAPH) -> Single<SubmissionCalendar> {
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
    
    public func request<T>(type: T.Type, graph: GRAPH) -> Maybe<T> {
        let query = API.GRAPH_QUERY(path: graph)
        
        switch query {
        case let q as FetchSolvedProblemQuery:
            return getSolvedProblems(q) as! Maybe<T>
//        case let q as FetchSolvedProblemQuery:
//            break
//        case let q as FetchMeQuery:
//            break
//        case let q as UpdateNickNameMutation:
//            break
//        case let q as SubmitSubmissionMutation:
//            break
//        case let q as FetchProblemsQuery:
//            break
//        case let q as FetchProblemByIdQuery:
//            break
//        case let q as FetchAllTagQuery:
//            break
//        case let q as FetchAllLanguageQuery:
//            break
//        case let q as FetchMeSubmissionsQuery:
//            break
//        case let q as FetchSubmissionsQuery:
//            break
        default:
            break
        }
        return .empty()
    }
    
    
    typealias MatchMember = FetchSolvedProblemQuery.Data.MatchMember.SolvedProblem.Fragments
    
    public func getSolvedProblems(_ query: FetchSolvedProblemQuery) -> Maybe<[ProblemIdentityFR]>  {
//        let query = API.GRAPH_QUERY(path: graph) as! FetchSolvedProblemQuery
        return graphAPI.fetch(query: query , cachePolicy: .default, queue: .main)
            .map { item in
                item.matchMember.solvedProblems.map { $0.fragments.problemIdentityFR }
            }
    }
    
    public func getMe(_ graph: GRAPH) -> Maybe<MemberFR> {
        let query = API.GRAPH_QUERY(path: graph) as! FetchMeQuery
        return graphAPI.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, queue: .main)
            .map { item in
                item.getMe.fragments.memberFR
            }
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.tokenAcquizition)
            })
    }
    
    public func updateNickName(_ graph: GRAPH) -> Maybe<MemberFR> {
        let mutation = API.GRAPH_MUTATION(path: graph) as! UpdateNickNameMutation
        return graphAPI.perform(query: mutation, cachePolichy: .default, queue: .global(qos: .default))
            .map { item in
                item.updateNickname.fragments.memberFR
            }
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.tokenAcquizition)
            })
    }
    
    public func perform(_ graph: GRAPH, max retry: Int = 2) -> Maybe<SubmissionFR> {
        let mutation = API.GRAPH_MUTATION(path: graph) as! SubmitSubmissionMutation
        return graphAPI.perform(query: mutation, cachePolichy: .default, queue: .main)
            .map { item in
                item.createSubmission.fragments.submissionFR
            }
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.tokenAcquizition)
            }) // retry
    }
    
    public func getProblemsQuery(_ graph: GRAPH) -> Maybe<([ProblemFR],PageInfoFR)> {
        let query = API.GRAPH_QUERY(path: graph) as! FetchProblemsQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { item in
                let content = item.getProblems.content!
                let fproblems = content.compactMap { content in
                    content.fragments.problemFR
                }
                let fpageInfo = item.getProblems.pageInfo.fragments.pageInfoFR
                return (fproblems, fpageInfo)
            }
    }
    
    public func getProblemByID(_ graph: GRAPH) -> Maybe<ProblemFR> {
        let query = API.GRAPH_QUERY(path: graph) as! FetchProblemByIdQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                data.getProblemById.fragments.problemFR
            }
    }
    
    public func getAllTag(_ graph: GRAPH) -> Maybe<([TagFR],PageInfoFR)> {
        //tag: 완전 탐색
        //tag: 4
        //tag: 자료 구조
        let query = API.GRAPH_QUERY(path: graph) as! FetchAllTagQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                let ftags: [TagFR] = data.getAllTag.content!.map { content in
                    content.fragments.tagFR
                }
                let pageInfo = data.getAllTag.pageInfo.fragments.pageInfoFR
                return (ftags,pageInfo)
            }
    }
    
    public func getAllLanguage(_ graph: GRAPH) -> Maybe<[LanguageFR]> {
        let query = API.GRAPH_QUERY(path: graph) as! FetchAllLanguageQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                data.getAllLanguage.map { content in
                    content.fragments.languageFR
                }
            }
    }
    
    public func getMeSubmissions(_ graph: GRAPH) -> Maybe<[SubmissionFR]> {
        let query = API.GRAPH_QUERY(path: graph) as! FetchMeSubmissionsQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                data.matchMember.submissions.map { submission in
                    submission.fragments.submissionFR
                }
            }
    }
    
    public func getSubmission(_ graph: GRAPH, cache: CachePolicy? = nil) -> Maybe<([SubmissionFR],PageInfoFR)> {
        let query = API.GRAPH_QUERY(path: graph) as! FetchSubmissionsQuery
        return graphAPI.fetch(query: query, cachePolicy: cache ?? .default, queue: .main)
            .map { data in
                guard let contents = data.getSubmissions.content else { return ([],.init(_fieldData: nil)) }
                let fsubmissions = contents.map { content in
                    content.fragments.submissionFR
                }
                let pageInfo = data.getSubmissions.pageInfo.fragments.pageInfoFR
                return (fsubmissions, pageInfo)
            }
    }
    
    
    public func signUp(member: MemberDTO) -> Maybe<Bool> {
        restAPI.request(.rest(.regitster(member))) { data in
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
}

