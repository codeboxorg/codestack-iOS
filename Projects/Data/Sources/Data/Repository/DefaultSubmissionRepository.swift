//
//  DefaultSubmissionRepository.swift
//  Data
//
//  Created by 박형환 on 2/26/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import Domain
import CodestackAPI
import Apollo
import CSNetwork
import Global

protocol GraphQLSubmissionRepository {
    func perform(_ mutation: SubmitMutation, max retry: Int) -> Maybe<SubmissionVO>
    func getProblemsQuery(_ query: GRQuery) -> Maybe<([ProblemVO],PageInfoVO)>
    
    func getSubmission(_ query: GRQuery) -> Maybe<([SubmissionVO],PageInfoVO)>
    func getSolvedProblems(_ username: String) -> Maybe<[ProblemIdentityVO]>
    func getProblemByID(_ problemID: String) -> Maybe<ProblemVO>
    func getAllTag() -> Maybe<([TagVO],PageInfoVO)>
    func getAllLanguage() -> Maybe<[LanguageVO]>
    
    func getMeSubmissions(_ name: String) -> Maybe<[SubmissionVO]>
}


public enum SubmissionError: Error {
    case notImplement
}

public final class DefaultSubmissionRepository: SubmissionRepository {
    
    private var tokenAcquizition: TokenAcquisitionService<RefreshToken>
    private var graphAPI: GraphQLAPI
    private let restAPI: RestAPI
    
    public init(tokenAcquizition: TokenAcquisitionService<RefreshToken>,
                graphAPI: GraphQLAPI,
                restAPI: RestAPI)
    {
        self.tokenAcquizition = tokenAcquizition
        self.graphAPI = graphAPI
        self.restAPI = restAPI
    }
    
    public func performSubmit(_ mutation: SubmissionVO, max retry: Int) -> Maybe<SubmissionVO> {
        var mutation = mutation
        mutation.statusCode = .RE
        mutation.createdAt = Date().toString()
        mutation.memoryUsage = -1
        mutation.cpuTime = -1
        Log.debug("mutation: \(mutation)")
        return Maybe.just(mutation) // return .error(SubmissionError.notImplement)
    }
    
    public func fetchProblemsQuery(_ query: GRQuery) -> Maybe<([ProblemVO], PageInfoVO)> {
        // getProblemsQuery(query)
        return .error(SubmissionError.notImplement)
    }
    
    public func fetchProblemByID(_ problemID: String) -> Maybe<ProblemVO> {
        let token = KeychainItem.currentFBIdToken
        let endPoint = FireStoreProblemEndPoint(token, problemID: problemID)
        return restAPI.request(endPoint, operation: { data in
            try JSONDecoder().decode([QueryResult<ProblemDTO>].self, from: data)
        })
        .compactMap {
            $0.compactMap {
                $0.document
            }.map {
                $0.toDomain()
            }.first
        }
    }
    
    public func fetchAllTag() -> Maybe<([TagVO],PageInfoVO)> {
        return .error(SubmissionError.notImplement)
    }
    
    public func fetchAllLanguage() -> Maybe<[LanguageVO]> {
        return .error(SubmissionError.notImplement)
    }
    
    public func fetchMeSubmissions(_ name: String) -> Maybe<[SubmissionVO]> {
        return .error(SubmissionError.notImplement)
    }
    
    public func fetchSubmission(_ query: GRQuery) -> Maybe<([SubmissionVO],PageInfoVO)> {
        return .error(SubmissionError.notImplement)
    }
    
    public func perform(_ mutation: SubmitMutation, max retry: Int = 2) -> Maybe<SubmissionVO> {
        let submitMutation = GRSubmit(languageId: mutation.languageId,
                                      problemId: mutation.problemId,
                                      sourceCode: mutation.sourceCode)
        
        let mutation = API.GRAPH_MUTATION(path: .SUBMIT_SUB(submit: submitMutation)) as! SubmitSubmissionMutation
        return graphAPI.perform(query: mutation, cachePolichy: .default, queue: .main)
            .timeout(.milliseconds(400), scheduler: MainScheduler.instance)
            .map { item in
                item.createSubmission.fragments.submissionFR.toDomain()
            }
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.tokenAcquizition)
            })
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
                                                              order: query.order))) as! FetchSubmissionsQuery
        return graphAPI.fetch(query: query, cachePolicy: .default, queue: .main)
            .timeout(.milliseconds(400), scheduler: MainScheduler.instance)
            .map { data in
                let contents = data.getSubmissions.content!
                
                let fsubmissions = contents.map { content in
                    content.fragments.submissionFR.toDomain()
                }
                let pageInfo = data.getSubmissions.pageInfo.fragments.pageInfoFR.toDomain()
                return (fsubmissions, pageInfo)
            }
    }
}
