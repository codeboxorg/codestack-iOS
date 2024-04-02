//
//  ProblemUsecase.swift
//  Domain
//
//  Created by 박형환 on 12/15/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift

public final class ProblemUsecase {
    
    public struct Dependency {
        let web: WebRepository
        let db: DBRepository
        let sub: SubmissionRepository
        let fb: FBRepository
        
        public init(web: WebRepository, 
                    db: DBRepository,
                    sub: SubmissionRepository,
                    fb: FBRepository) {
            self.web = web
            self.db = db
            self.sub = sub
            self.fb = fb
        }
    }
    
    private let webRepository: WebRepository
    private let dbRepoistory: DBRepository
    private let submissionRepository: SubmissionRepository
    private let firebaseRepository: FBRepository
    
    public init(dependency: Dependency) {
        self.webRepository = dependency.web
        self.dbRepoistory = dependency.db
        self.submissionRepository = dependency.sub
        self.firebaseRepository = dependency.fb
    }
    
    public func upLoadProblem(_ problemVO: ProblemVO) -> Observable<State<Void>> {
        firebaseRepository.uploadProblem(problemVO)
    }
    
    public func fetchProblemList() -> Observable<[ProblemVO]> {
        firebaseRepository.fetchProblem()
    }
    
    public func fetchProblems(offset: Int) -> Observable<ProblemInfoVO> {
        submissionRepository
            .fetchProblemsQuery(GRQuery(offset: offset))
            .timeout(.seconds(1), scheduler: MainScheduler.instance)
            .map { list, info in ProblemInfoVO(probleminfoList: list, pageInfo: info) }
            .asObservable()
    }
    
    public func problemSelectAction(problemID: ProblemID) -> Observable<[SubmissionVO]> {
        return dbRepoistory
            .fetchProblemState(.all)
            .timeout(.seconds(1), scheduler: MainScheduler.instance)
            .compactMap(\.first?.submissions)
            .asObservable()
    }
    
}
