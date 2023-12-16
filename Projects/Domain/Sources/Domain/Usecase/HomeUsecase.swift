//
//  HomeUsecase.swift
//  Domain
//
//  Created by 박형환 on 12/15/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import Global

public final class HomeUsecase {
    
    private let webRepository: WebRepository
    private let dbRepository: DBRepository
    
    public init(webRepository: WebRepository, dbRepository: DBRepository) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
    }
    
    public func fetchSubmissionList() -> Observable<[SubmissionVO]> {
        dbRepository
            .fetchProblemState()
            .map(\.first)
            .map { problemState in
                if let problemState { return problemState.submissions.sortByDate() }
                else { return [] }
            }
            .asObservable()
    }
    
    public func fetchProblem(using subVO: SubmissionVO) -> Observable<SubmissionVO> {
        webRepository
            .getProblemByID(subVO.problem.id)
            .map { /*prFR*/ prVo in
                let problemVO = prVo /*.toDomain()*/
                var submission = subVO
                submission.problemVO = problemVO
                return submission
            }
            .asObservable()
    }
}
