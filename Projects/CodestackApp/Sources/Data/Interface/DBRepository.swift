//
//  DBRepository.swift
//  CodestackApp
//
//  Created by 박형환 on 12/14/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift

protocol DBRepository: AnyObject {
    func fetch(_ requestType: SubmissionMO.RequestType) -> Single<[SubmissionVO]>
    func store(submission: SubmissionVO) -> Single<Void>
    func remove() -> Single<Void>
    func remove(_ requestType: SubmissionMO.RequestType) -> Completable
    func update(submission: SubmissionVO, type request: SubmissionMO.RequestType) -> Single<Void>
    
    func fetchProblemState() -> Single<[ProblemSubmissionState]>
    func fetchSubmissionCalendar() -> Single<[SubmissionCalendar]>
    
    func store(favoriteProblem: FavoriteProblem) -> Single<Void>
    func fetchFavoriteProblems() -> Single<[FavoriteProblem]>
    func removeFavor(_ requestType: FavoritProblemMO.RequestType) -> Completable
}
