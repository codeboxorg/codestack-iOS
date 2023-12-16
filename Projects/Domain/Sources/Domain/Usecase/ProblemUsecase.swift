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
    
    private let webRepository: WebRepository
    
    public init(webRepository: WebRepository) {
        self.webRepository = webRepository
    }
    
    public func fetchProblems(offset: Int) -> Observable<[ProblemVO]> {
        webRepository
            .getProblemsQuery(GRQuery(offset: offset))
//            .getProblemsQuery(.PR_LIST(arg: GRAR(offset: offset)))
            .map { $0.0 }
            .asObservable()
        // TODO: Page Info 확인하기
        //  .asSignal(onErrorJustReturn: [])
    }
    
}
