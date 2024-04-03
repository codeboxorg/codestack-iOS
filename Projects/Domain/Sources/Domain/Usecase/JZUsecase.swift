//
//  JZUsecase.swift
//  Domain
//
//  Created by 박형환 on 4/22/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift


public enum JZErrorType: Error {
    case proccesing
    case complte
    case exccedLimit
    case unknown
}

public struct JZQuery {
    public let code: String
    public let language: LanguageVO
    public let nickname: String
    public let problem: ProblemVO
    
    public init(code: String, 
                language: LanguageVO,
                problem: ProblemVO,
                nickname: String) {
        self.code = code
        self.language = language
        self.problem = problem
        self.nickname = nickname
    }
    
    public var languageID: Int {
        Int(self.language.id) ?? 0
    }
}

public final class JZUsecase {
    
    private let repo: JZSubmissionRepository
    private var user: MemberVO?
    
    public init(repo: JZSubmissionRepository) {
        self.repo = repo
    }
    
    public func submissionPerform(query: JZQuery) -> Observable<State<SubmissionVO>> {
        self.perform(query.code, query.languageID, query.problem)
            .withUnretained(self)
            .flatMap { usecase, token in usecase.get(token: token) }
            .withUnretained(self)
            .map { usecase, result in result.toSubmissionVO(query: query) }
            .map { result in .success(result) }
            .catch { value in .just(.failure(value)) }
    }
    
    private func perform(_ code: String, _ languageID: Int, _ problemVO: ProblemVO) -> Observable<State<SubmissionToken>> {
        repo.perform(code: code, languageID: languageID, problemVO: problemVO)
    }
    
    private func get(token: State<SubmissionToken>) -> Observable<JudgeZeroSubmissionVO> {
        switch token {
        case let .success(token):
            return repo.getSubmission(token: token)
        case let .failure(error):
            return Observable.error(error)
        }
    }
}
