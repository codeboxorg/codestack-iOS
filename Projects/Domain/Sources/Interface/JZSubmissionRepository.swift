//
//  JZSubmissionRepository.swift
//  Domain
//
//  Created by 박형환 on 4/22/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift

public typealias SubmissionToken = String
public protocol JZSubmissionRepository {    
    func perform(code: String, languageID: Int, problemVO: ProblemVO) -> Observable<State<SubmissionToken>>
    func getSubmission(token: SubmissionToken) -> Observable<JudgeZeroSubmissionVO>
    func jzAuthentificate() -> Observable<Bool>
}
