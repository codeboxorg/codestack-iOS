//
//  ApolloService.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/25.
//

import Foundation
import RxSwift
import CodestackAPI



protocol ApolloServiceProtocol{
    func request(query: GetAllLanguageQuery, completion: @escaping (Result<[Language],Error>) -> () )
    func request(query: GetSubmissionsQuery, completion: @escaping (Result<[Submission],Error>) -> () )
    func request(query: GetAllTagQuery, completion: @escaping (Result<[Tag],Error>) -> () )
    func request(query: GetProblemsQuery,_ completion: @escaping (Result<[_Problem],Error>) -> () )
    
    func perform(mutation: CreateSubmissionMutation) -> Maybe<CreateSubmissionMutation.Data>
}


//if (status === 'AC') return <Tag color='green'>정답</Tag>
//   if (status === 'WA') return <Tag color='red'>오답</Tag>
//   if (status === 'PE') return <Tag color='yellow'>출력 형식 다름</Tag>
//   if (status === 'TLE') return <Tag color='red'>시간 초과</Tag>
//   if (status === 'MLE') return <Tag color='red'>메모리 초과</Tag>
//   if (status === 'OLE') return <Tag color='yellow'>값 출력 초과</Tag>

class ApolloService: ApolloServiceProtocol{
    
    
    private var repository: Repository = ApolloRepository.shared

    
    func perform(mutation: CreateSubmissionMutation) -> Maybe<CreateSubmissionMutation.Data>
    {
        return repository.perform(query: mutation, cachePolichy: .default, queue: .main)
    }
    
    //.perform(query: mutation, cachePolichy: .default, queue: .main)
//            .subscribe(onSuccess: { data in
//                let submission = ConvertUtil.converting(submission: data.createSubmission)
//                completion(.success(submission))
//            },onError: { err in
//                completion(.failure(err))
//            },onCompleted: {
//
//            },onDisposed: {
//
//            })
    
    
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
    
    
    
    func request(query: GetAllLanguageQuery,
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
    
    
    func request(query: GetSubmissionsQuery,
                 completion: @escaping (Result<[Submission],Error>) -> () )
    {
        _ = repository
            .fetch(query: query, cachePolicy: .default, queue: DispatchQueue.main)
            .subscribe(onSuccess: { sub in
                let submissions = ConvertUtil.converting(all: sub.getSubmissions)
            }, onError: { err in
                
            }, onCompleted: {
                
            }, onDisposed: {
                
            })
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

