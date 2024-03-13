//
//  MockSubmissionRepository.swift
//  Domain
//
//  Created by 박형환 on 2/26/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift
@testable import Domain


enum SubmissionError: Error {
    case notImplement
    case performFail
}

public extension ProblemVO {
    static let a = ProblemVO.init(id: "1", title: "a", context: "", languages: [], tags: [], accepted: 0, submission: 0, maxCpuTime: "", maxMemory: 0)
    static let b = ProblemVO.init(id: "2", title: "b", context: "", languages: [], tags: [], accepted: 0, submission: 0, maxCpuTime: "", maxMemory: 0)
    static let c = ProblemVO.init(id: "3", title: "c", context: "", languages: [], tags: [], accepted: 0, submission: 0, maxCpuTime: "", maxMemory: 0)
    static let d = ProblemVO.init(id: "4", title: "d", context: "", languages: [], tags: [], accepted: 0, submission: 0, maxCpuTime: "", maxMemory: 0)
    static let e = ProblemVO.init(id: "5", title: "e", context: "", languages: [], tags: [], accepted: 0, submission: 0, maxCpuTime: "", maxMemory: 0)
    static let f = ProblemVO.init(id: "6", title: "f", context: "", languages: [], tags: [], accepted: 0, submission: 0, maxCpuTime: "", maxMemory: 0)
    
    static let allcase: [ProblemVO] = [ .a,.b,.c,.d,.e,.f ]
}

public final class MockSubmissionRepository: SubmissionRepository {
    
    
    public struct State {
        public var problem: [ProblemVO] = ProblemVO.allcase
        
        public var tags: [TagVO] = 
        [
            .init(id: "1", name: "알고리즘"),
            .init(id: "2", name: "구현"),
            .init(id: "3", name: "수학"),
            .init(id: "4", name: "탐색"),
            .init(id: "5", name: "트리")
        ]
        
        public var languages: [LanguageVO] = LanguageVO.sample
        
        public var submissions: [SubmissionVO] = [SubmissionVO.sample, SubmissionVO.mock]
    }
    
    public var state: State = .init()
    
    public func performSubmit(_ mutation: Domain.SubmissionVO, max retry: Int) -> RxSwift.Maybe<Domain.SubmissionVO> {
        var mutation = mutation
        mutation.statusCode = .RE
        mutation.createdAt = Date().toString()
        mutation.memoryUsage = -1
        mutation.cpuTime = -1
        
        state.submissions.append(mutation)
        
        return Maybe.just(mutation)
    }
    
    public func fetchProblemsQuery(_ query: GRQuery) -> Maybe<([ProblemVO], PageInfoVO)> {
        // getProblemsQuery(query)
        return .just((state.problem,.init(limit: 0, offset: 0, totalContent: 6, totalPage: 1)))
    }
    
    public func fetchProblemByID(_ problemID: String) -> Maybe<ProblemVO> {
        if let problem = state.problem.filter { $0.id == problemID }.first
        {
            return .just(problem)
        }
        else 
        {
            return .error(SubmissionError.notImplement)
        }
    }
    
    public func fetchAllTag() -> Maybe<([TagVO],PageInfoVO)> {
        
        return .just((state.tags, .init(limit: 0, offset: 0, totalContent: state.tags.count, totalPage: 1)))
    }
    
    public func fetchAllLanguage() -> Maybe<[LanguageVO]> {
        
        return .just(state.languages)
    }
    
    public func fetchMeSubmissions(_ name: String) -> Maybe<[SubmissionVO]> {
        .just(state.submissions.filter { $0.member.username == name })
    }
    
    public func fetchSubmission(_ query: GRQuery) -> Maybe<([SubmissionVO],PageInfoVO)> {
        return .just((state.submissions, .init(limit: 0, offset: 0, totalContent: state.submissions.count, totalPage: 1)))
    }
}
