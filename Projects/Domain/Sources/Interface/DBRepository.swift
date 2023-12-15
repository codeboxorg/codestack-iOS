//
//  DBRepository.swift
//  CodestackApp
//
//  Created by 박형환 on 12/14/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift


public protocol DBRepository: AnyObject {
    func fetch(_ requestType: SUB_TYPE) -> Single<[SubmissionVO]>
    func store(submission: SubmissionVO) -> Single<Void>
    func remove() -> Single<Void>
    func remove(_ requestType: SUB_TYPE) -> Completable
    func update(submission: SubmissionVO, type request: SUB_TYPE) -> Single<Void>
    
    func fetchProblemState() -> Single<[ProblemSubmissionStateVO]>
    func fetchSubmissionCalendar() -> Single<[SubmissionCalendarVO]>
    
    func store(favoriteProblem: FavoriteProblemVO) -> Single<Void>
    func fetchFavoriteProblems() -> Single<[FavoriteProblemVO]>
    func removeFavor(_ requestType: FAV_TYPE) -> Completable
}

public typealias ProblemID = String
public typealias StatusCode = String
public typealias SubmissionID = String
public typealias LanguageName = String

/// SubmissionMO - Request Type
public enum SUB_TYPE {
    case isExist(ProblemID)
    case isNotTemp(ProblemID, StatusCode)
    case isEqualStatusCode(StatusCode)
    case update(SubmissionID, ProblemID)
    case recent(ProblemID)
    case `default`
    case delete(LanguageName, ProblemID, StatusCode)
}

/// ProblemSubmissionStateMO - Request Type
public enum PR_SUB_ST_TYPE {
    case all
    case isEqualID(ProblemID)
}

/// FavoritProblemMO - Request Type
public enum FAV_TYPE {
    case all
    case isEqualID(ProblemID)
}