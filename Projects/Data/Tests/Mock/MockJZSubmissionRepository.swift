//
//  MockJZSubmissionRepository.swift
//  Data
//
//  Created by 박형환 on 4/24/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
@testable import CSNetwork
@testable import Domain
import RxSwift
import XCTest

final class MockJZSubmissionRepository: JZSubmissionRepository {
    
    private var restAPI: RestAPI
    
    init(_ restAPI: RestAPI) {
        self.restAPI = restAPI
    }
    
    func perform(code: String, languageID: Int, problemVO: ProblemVO) -> Observable<State<SubmissionToken>> {
        .empty()
    }
    
    func getSubmission(token: SubmissionToken) -> Observable<JudgeZeroSubmissionVO> {
        .empty()
    }
    
    func jzAuthentificate() -> Observable<Bool> {
        .empty()
    }
}
