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
    func getAllLanguage(query: GetAllLanguageQuery, completion: @escaping (Result<[Language],Error>) -> () )
    func getMeSubmissions(query: GetMeSubmissionsQuery) -> Maybe<GetMeSubmissions>
    func getSubmission(query: GetSubmissionsQuery) -> Maybe<GetSubmissions>
    func request(query: GetAllTagQuery, completion: @escaping (Result<[Tag],Error>) -> () )
    func request(query: GetProblemsQuery,_ completion: @escaping (Result<[_Problem],Error>) -> () )
    func request(query: GetMeQuery) -> Maybe<GetMeQuery.Data.GetMe>
    func request(query: GetSolvedProblemQuery) -> Maybe<SolvedProblems>
    func perform(mutation: CreateSubmissionMutation, max retry: Int) -> Maybe<CreateSubmissionMutation.Data>
}



public typealias Token = String
public typealias SolvedProblems = [GetSolvedProblemQuery.Data.MatchMember.SolvedProblem]
public typealias GetSubmissions = GetSubmissionsQuery.Data.GetSubmissions
public typealias GetMeSubmissions = [GetMeSubmissionsQuery.Data.GetMe.Submission]

class ApolloService: ApolloServiceType{
    
    private var tokenAcquizition: TokenAcquisitionService<CodestackResponseToken>
    private var repository: Repository
    
    init(dependency: TokenAcquisitionService<CodestackResponseToken> ){
        self.tokenAcquizition = dependency
        self.repository = ApolloRepository(dependency: self.tokenAcquizition)
    }

    
    func request(query: GetSolvedProblemQuery) -> Maybe<SolvedProblems> {
        repository.fetch(query: query, cachePolicy: .default, queue: .main)
            .map { data in
                data.matchMember.solvedProblems
            }
    }
    
    
    func request(query: GetMeQuery) -> Maybe<GetMeQuery.Data.GetMe>{
        repository.fetch(query: query, cachePolicy: .default, queue: .main)
            .map{ data in
                data.getMe
            }
    }
    
    
    func perform(mutation: CreateSubmissionMutation, max retry: Int = 3) -> Maybe<CreateSubmissionMutation.Data>
    {
        return repository.perform(query: mutation, cachePolichy: .default, queue: .main)
            .retry(when: { [unowned self] errorObservable in
                return errorObservable.renewToken(with: self.tokenAcquizition)
            })// retry
    }
    
    func request<Query,Response>(query: Query,
                                 type: Response.Type,
                                 completion: @escaping ((Result<Response, Error>) -> Void))
    where Query: GraphQLQuery, Response: Decodable, Response: Encodable {
        
    }
    
    
    func request(query: GetProblemsQuery,
                 _ completion: @escaping (Result<[_Problem],Error>) -> ())
    {
        _ = repository
            .fetch(query: query, cachePolicy: .default, queue: DispatchQueue.main)
            .subscribe(with: self, onSuccess: { service, data in
                let problems = ConvertUtil.converting(problems: data.getProblems)
                completion(.success(problems))
            },onError: { _,err in
                Log.error(err)
                completion(.failure(err))
            },onCompleted: { _ in
                Log.debug("complte")
            },onDisposed: { _ in
                Log.debug("disposed")
            })
    }
    
    func request(query: GetAllTagQuery,
                 completion: @escaping (Result<[Tag],Error>) -> ())
    {
        //tag: 완전 탐색
        //tag: 4
        //tag: 자료 구조
        
        _ = repository
            .fetch(query: query, cachePolicy: .default, queue: DispatchQueue.main)
            .subscribe(with: self, onSuccess: { service, data in
                let languages = ConvertUtil.converting(tag: data.getAllTag)
                completion(.success(languages))
            },onError: { _,err in
                Log.error(err)
                completion(.failure(err))
            },onCompleted: { _ in
                Log.debug("complte")
            },onDisposed: { _ in
                Log.debug("disposed")
            })
    }
    
    
    
    func getAllLanguage(query: GetAllLanguageQuery,
                 completion: @escaping (Result<[Language],Error>) -> () )
    {
        _ = repository
            .fetch(query: query, cachePolicy: .default, queue: DispatchQueue.main)
            .subscribe(with: self, onSuccess: { service, data in
                let languages = ConvertUtil.converting(data: data.getAllLanguage)
                completion(.success(languages))
            },onError: { _,err in
                Log.error(err)
                completion(.failure(err))
            },onCompleted: { _ in
                Log.debug("complte")
            },onDisposed: { _ in
                Log.debug("disposed")
            })
    }
    
    func getMeSubmissions(query: GetMeSubmissionsQuery) -> Maybe<GetMeSubmissions>{
        repository
            .fetch(query: query, cachePolicy: .default, queue: .main)
            .map{ $0.getMe.submissions }
    }
    
    
    func getSubmission(query: GetSubmissionsQuery) -> Maybe<GetSubmissions>{
        let op = GetSubmissionsQuery.operationName.lowercased()
        return repository
            .fetch(query: query, cachePolicy: .default, queue: DispatchQueue.main)
            .map{ data in
//                let dict = data.__data[op]
//                if let dict{
//                    print(dict)
//                }
                return data.getSubmissions
                
            }
    }
    
    
    
    func send(mutation: CreateSubmissionMutation){
        _ = repository
            .perform(query: mutation, cachePolichy: .default, queue: DispatchQueue.main)
            .subscribe(onSuccess: { sub in
                sub.createSubmission.id
            }, onError: { err in
                
            }, onCompleted: {
                
            }, onDisposed: {
                
            })
    }
}

