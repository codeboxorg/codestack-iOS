//
//  HomeUsecase.swift
//  Domain
//
//  Created by 박형환 on 12/15/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift

public final class HomeUsecase {
    
    private var disposebag = DisposeBag()
    private let webRepository: WebRepository
    private let dbRepository: DBRepository
    private let submissionRepository: SubmissionRepository
    
    public init(webRepository: WebRepository,
                dbRepository: DBRepository,
                submissionRepository: SubmissionRepository) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.submissionRepository = submissionRepository
    }
    
    #if DEBUG
    public func removeForTest() {
//        dbRepository.removeAll()
//            .subscribe(onDisposed:  {
//                Log.debug("completed")
//            })
    }
    #endif
    
    public func fetchSubmissionList() -> Observable<[SubmissionVO]> {
        dbRepository
            .fetchProblemState(.all)
            .map(\.first)
            .map { problemState in
                if let problemState { return problemState.submissions.sortByDate() }
                else { return [] }
            }
            .asObservable()
    }
    
    public func fetchSubmissionEqual(_ code: SolveStatus) -> Observable<[SubmissionVO]> {
        dbRepository.fetch(.isEqualStatusCode(code))
            .asObservable()
            .map { $0 }
    }
    
    public func fetchProblem(using subVO: SubmissionVO) -> Observable<SubmissionVO> {
        dbRepository
            .fetch(.is_Equal_ST_ID(subVO.id, subVO.statusCode))
            .compactMap { $0.first }
            .flatMap { [weak submissionRepository] vo in
                guard let submissionRepository else { return .just(vo) }
                return submissionRepository
                    .fetchProblemByID(subVO.problem.id)
                    .timeout(.milliseconds(400), scheduler: MainScheduler.instance)
                    .map { prVO in
                        var subVo = vo
                        subVo.problemVO = prVO
                        return subVO
                    }
                    .catchAndReturn(vo)
            }.asObservable()
    }
}
