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
        let dto = MemberDTO(id: "id", password: "pwd", email: member.email, nickName: member.nickName)
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
    
    
    // MARK: MayBe after solve Dependency Circular Problem
//    public func getSolvedProblems(_ username: String) -> Maybe<[ProblemIdentityVO]>
//    public func getMe() -> Maybe<MemberVO>
//    public func updateNickName(_ nickname: String) -> Maybe<MemberVO>
//    public func perform(_ mut: GraphMutation, max retry: Int = 2) -> Maybe<SubmissionVO>
//    public func getProblemsQuery(_ query: GraphQLQuery) -> Maybe<([ProblemVO], PageInfoVO)>
//    public func getProblemByID(_ problemID: String) -> Maybe<ProblemVO>
//    public func getAllTag() -> Maybe<([TagVO],PageInfoVO)>
//    public func getAllLanguage() -> Maybe<[LanguageVO]>
//    public func getSubmission(_ query: GraphQLQuery, cache: CachePolicy? = nil) -> Maybe<([SubmissionVO],PageInfoVO)>
//    public func getMeSubmissions(_ name: String) -> Maybe<[SubmissionVO]>
    
    
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
    
    public func perform(_ mutation: SubmitMutation, max retry: Int = 2) -> Maybe<SubmissionVO> {
        let submit = SubmitMutation(languageId: mutation.languageId,
                                    problemId: mutation.problemId,
                                    sourceCode: mutation.sourceCode)
        let mutation = API.GRAPH_MUTATION(path: .SUBMIT_SUB(submit: submit)) as! SubmitSubmissionMutation
        return graphAPI.perform(query: mutation, cachePolichy: .default, queue: .main)
            .map { item in
                item.createSubmission.fragments.submissionFR.toDomain()
            }
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.tokenAcquizition)
            }) // retry
    }
    
    public func getProblemsQuery(_ query: GRQuery) -> Maybe<([ProblemVO], PageInfoVO)> {
        let query = API.GRAPH_QUERY(path: .PR_LIST(arg: GRAR(limit: query.limit ,
                                                             offset: query.offset,
                                                             sort: query.sort,
                                                             order: query.order))) as! FetchProblemsQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { item in
                let content = item.getProblems.content!
                let fproblems = content.compactMap { content in
                    content.fragments.problemFR.toDomain()
                }
                let fpageInfo = item.getProblems.pageInfo.fragments.pageInfoFR.toDomain()
                return (fproblems, fpageInfo)
            }
    }
    
    public func getProblemByID(_ problemID: String) -> Maybe<ProblemVO> {
        let query = API.GRAPH_QUERY(path: .PR_BY_ID(problemID)) as! FetchProblemByIdQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                data.getProblemById.fragments.problemFR.toDomain()
            }
    }
    
    public func getAllTag() -> Maybe<([TagVO],PageInfoVO)> {
        //tag: 완전 탐색
        //tag: 4
        //tag: 자료 구조
        let query = API.GRAPH_QUERY(path: .TAG_LIST) as! FetchAllTagQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                let ftags: [TagVO] = data.getAllTag.content!.map { content in
                    content.fragments.tagFR.toDomain()
                }
                let pageInfo = data.getAllTag.pageInfo.fragments.pageInfoFR.toDomain()
                return (ftags,pageInfo)
            }
    }
    
    public func getAllLanguage() -> Maybe<[LanguageVO]> {
        let query = API.GRAPH_QUERY(path: .LANG_LIST(offset: 0)) as! FetchAllLanguageQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                data.getAllLanguage.map { content in
                    content.fragments.languageFR.toDomain()
                }
            }
    }
    
    public func getMeSubmissions(_ name: String) -> Maybe<[SubmissionVO]> {
        let query = API.GRAPH_QUERY(path: .SUB_LIST_ME(username: name)) as! FetchMeSubmissionsQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                data.matchMember.submissions.map { submission in
                    submission.fragments.submissionFR.toDomain()
                }
            }
    }
    
    public func getSubmission(_ query: GRQuery) -> Maybe<([SubmissionVO],PageInfoVO)> {
        let query = API.GRAPH_QUERY(path: .SUB_LIST(arg: GRAR(limit: query.limit,
                                                              offset: query.offset,
                                                              sort: query.sort,
                                                              order: query.order)))
        as! FetchSubmissionsQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                let contents = data.getSubmissions.content!
                
                let fsubmissions = contents.map { content in
                    content.fragments.submissionFR.toDomain()
                }
                let pageInfo = data.getSubmissions.pageInfo.fragments.pageInfoFR.toDomain()
                return (fsubmissions, pageInfo)
            }
    }
    
    // MARK: 바꿔 야됨
//    public func signUp(member: MemberDTO) -> Maybe<Bool> {
//        restAPI.request(.rest(.regitster(member))) { data in
//            return true
//        }
//        .map { $0 }
//        .retry(when: { [weak self] errorObservable in
//            guard let self else { return Observable<Void>.never() }
//            return errorObservable.renewToken(with: self.tokenAcquizition)
//        })
//    }
//    
//    public func passwordChange(_ original: Pwd, new: Pwd) -> Maybe<Bool> {
//        restAPI.request(.rest(.password(original, new))) { _ in
//            return true
//        }
//        .map { $0 }
//        .retry(when: { [weak self] errorObservable in
//            guard let self else { return Observable<Void>.never() }
//            return errorObservable.renewToken(with: self.tokenAcquizition)
//        })
//    }
//    
//    public func editProfile(_ image: Data) -> Maybe<ImageURL> {
//        restAPI.request(.rest(.profile(image))) { data in
//            String(data: data, encoding: .utf8)
//        }
//        .map { $0 }
//        .retry(when: { [weak self] errorObservable in
//            guard let self else { return Observable<Void>.never() }
//            return errorObservable.renewToken(with: self.tokenAcquizition)
//        })
//    }
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

//    func getSubmissionDate(api: GRAPH) -> Single<SubmissionCalendar> {
//        // TODO: 현재 GraphQL API에 Submission Result Date 모델을 가져오는 API가 없다.
//        #if DEBUG
//        Single.create { single in
//            let calendars = SubmissionCalendar.generateMockCalendar()
//            single(.success(calendars))
//            return Disposables.create { }
//        }
//        #endif
////        api.fetch(query: query,
////                   cachePolicy: .fetchIgnoringCacheData,
////                   queue: .global(qos: .background))
////            .map { value in
////                value.getSubmissions.content?.compactMap { SubmissionCalendar(date: $0.createdAt) } ?? []
////            }
////            .asObservable()
////            .asSingle()
//    }
//
//    public func request<T>(type: T.Type, graph: GRAPH) -> Maybe<T> {
//        let query = API.GRAPH_QUERY(path: graph)
//
//        switch query {
////        case let q as FetchSolvedProblemQuery:
//            return getSolvedProblems(q) as! Maybe<T>
////        case let q as FetchSolvedProblemQuery:
////            break
////        case let q as FetchMeQuery:
////            break
////        case let q as UpdateNickNameMutation:
////            break
////        case let q as SubmitSubmissionMutation:
////            break
////        case let q as FetchProblemsQuery:
////            break
////        case let q as FetchProblemByIdQuery:
////            break
////        case let q as FetchAllTagQuery:
////            break
////        case let q as FetchAllLanguageQuery:
////            break
////        case let q as FetchMeSubmissionsQuery:
////            break
////        case let q as FetchSubmissionsQuery:
////            break
//        default:
//            break
//        }
//        return .empty()
//    }


//    typealias MatchMember = FetchSolvedProblemQuery.Data.MatchMember.SolvedProblem.Fragments
//
//    public func getSolvedProblems(_ query: FetchSolvedProblemQuery) -> Maybe<[ProblemIdentityVO]>  {
////        let query = API.GRAPH_QUERY(path: graph) as! FetchSolvedProblemQuery
//        return graphAPI.fetch(query: query , cachePolicy: .default, queue: .main)
//            .map { item in
//                item.matchMember
//                    .solvedProblems
//                    .map { $0.fragments.problemIdentityFR.toDomain() }
//            }
//    }

//    public func getMe(_ graph: GRAPH) -> Maybe<MemberVO> {
//        let query = API.GRAPH_QUERY(path: graph) as! FetchMeQuery
//        return graphAPI.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, queue: .main)
//            .map { item in
//                item.getMe.fragments.memberFR.toDomain()
//            }
//            .retry(when: { [weak self] errorObservable in
//                guard let self else { return Observable<Void>.never() }
//                return errorObservable.renewToken(with: self.tokenAcquizition)
//            })
//    }

//    public func updateNickName(_ graph: GRAPH) -> Maybe<MemberVO> {
//        let mutation = API.GRAPH_MUTATION(path: graph) as! UpdateNickNameMutation
//        return graphAPI.perform(query: mutation, cachePolichy: .default, queue: .global(qos: .default))
//            .map { item in
//                item.updateNickname.fragments.memberFR.toDomain()
//            }
//            .retry(when: { [weak self] errorObservable in
//                guard let self else { return Observable<Void>.never() }
//                return errorObservable.renewToken(with: self.tokenAcquizition)
//            })
//    }

//    public func perform(_ graph: GRAPH, max retry: Int = 2) -> Maybe<SubmissionVO> {
//        let mutation = API.GRAPH_MUTATION(path: graph) as! SubmitSubmissionMutation
//        return graphAPI.perform(query: mutation, cachePolichy: .default, queue: .main)
//            .map { item in
//                item.createSubmission.fragments.submissionFR.toDomain()
//            }
//            .retry(when: { [weak self] errorObservable in
//                guard let self else { return Observable<Void>.never() }
//                return errorObservable.renewToken(with: self.tokenAcquizition)
//            }) // retry
//    }

//    public func getProblemsQuery(_ graph: GRAPH) -> Maybe<([ProblemVO], PageInfoVO)> {
//        let query = API.GRAPH_QUERY(path: graph) as! FetchProblemsQuery
//        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
//            .map { item in
//                let content = item.getProblems.content!
//                let fproblems = content.compactMap { content in
//                    content.fragments.problemFR.toDomain()
//                }
//                let fpageInfo = item.getProblems.pageInfo.fragments.pageInfoFR.toDomain()
//                return (fproblems, fpageInfo)
//            }
//    }

//    public func getProblemByID(_ graph: GRAPH) -> Maybe<ProblemVO> {
//        let query = API.GRAPH_QUERY(path: graph) as! FetchProblemByIdQuery
//        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
//            .map { data in
//                data.getProblemById.fragments.problemFR.toDomain()
//            }
//    }

//    public func getAllTag(_ graph: GRAPH) -> Maybe<([TagVO],PageInfoVO)> {
//        //tag: 완전 탐색
//        //tag: 4
//        //tag: 자료 구조
//        let query = API.GRAPH_QUERY(path: graph) as! FetchAllTagQuery
//        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
//            .map { data in
//                let ftags: [TagVO] = data.getAllTag.content!.map { content in
//                    content.fragments.tagFR.toDomain()
//                }
//                let pageInfo = data.getAllTag.pageInfo.fragments.pageInfoFR.toDomain()
//                return (ftags,pageInfo)
//            }
//    }

//    public func getAllLanguage(_ graph: GRAPH) -> Maybe<[LanguageVO]> {
//        let query = API.GRAPH_QUERY(path: graph) as! FetchAllLanguageQuery
//        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
//            .map { data in
//                data.getAllLanguage.map { content in
//                    content.fragments.languageFR.toDomain()
//                }
//            }
//    }

//    public func getMeSubmissions(_ graph: GRAPH) -> Maybe<[SubmissionVO]> {
//        let query = API.GRAPH_QUERY(path: graph) as! FetchMeSubmissionsQuery
//        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
//            .map { data in
//                data.matchMember.submissions.map { submission in
//                    submission.fragments.submissionFR.toDomain()
//                }
//            }
//    }

//    public func getSubmission(_ graph: GRAPH, cache: CachePolicy? = nil) -> Maybe<([SubmissionVO],PageInfoVO)> {
//        let query = API.GRAPH_QUERY(path: graph) as! FetchSubmissionsQuery
//        return graphAPI.fetch(query: query, cachePolicy: cache ?? .default, queue: .main)
//            .map { data in
//                let contents = data.getSubmissions.content!
//
//                let fsubmissions = contents.map { content in
//                    content.fragments.submissionFR.toDomain()
//                }
//                let pageInfo = data.getSubmissions.pageInfo.fragments.pageInfoFR.toDomain()
//                return (fsubmissions, pageInfo)
//            }
//    }
//
