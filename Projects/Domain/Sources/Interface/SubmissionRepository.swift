//
//  SubmissionRepository.swift
//  Domain
//
//  Created by 박형환 on 2/26/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift

public protocol SubmissionRepository: AnyObject {
    func performSubmit(_ mutation: SubmissionVO, max retry: Int) -> Maybe<SubmissionVO>
    func fetchProblemsQuery(_ query: GRQuery) -> Maybe<([ProblemVO], PageInfoVO)>
    func fetchProblemByID(_ problemID: String) -> Maybe<ProblemVO>
    func fetchAllTag() -> Maybe<([TagVO],PageInfoVO)>
    func fetchAllLanguage() -> Maybe<[LanguageVO]>
    func fetchMeSubmissions(_ name: String) -> Maybe<[SubmissionVO]>
    func fetchSubmission(_ query: GRQuery) -> Maybe<([SubmissionVO],PageInfoVO)>
}
