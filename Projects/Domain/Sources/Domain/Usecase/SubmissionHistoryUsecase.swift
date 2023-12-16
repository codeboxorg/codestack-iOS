//
//  SubmissionHistoryUsecase.swift
//  CodeStack
//
//  Created by 박형환 on 12/2/23.
//

import Foundation
import RxSwift

public protocol HistoryUsecase {
    func fetchSubmission(offset: Int) -> Observable<[SubmissionVO]>
    func fetchMe(name: String) -> Observable<[SubmissionVO]>
    func fetchFavoriteProblem() -> Observable<State<[FavoriteProblemVO]>>
    func fetchProblemHistoryEqualStatus(status code: String) -> Observable<Result<[SubmissionVO], Error>>
}

public final class DefaultHistoryUsecase: HistoryUsecase {
    
    private let webRepository: WebRepository
    private let dbRepository: DBRepository
    
    public init(webRepository: WebRepository, dbRepository: DBRepository) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
    }
    
    public func fetchSubmission(offset: Int) -> Observable<[SubmissionVO]> {
        return webRepository
            .getSubmission(GRQuery(offset: offset))
//            .getSubmission(.SUB_LIST(arg: GRAR.init(offset: offset)), cache: nil)
            .map { frinfo in
                frinfo.0
                // TODO: 확인 -> Page INfo VO
            }
            .asObservable()
    }
    
    public func fetchMe(name: String) -> Observable<[SubmissionVO]> {
        webRepository
            .getMeSubmissions(name)
//            .getMeSubmissions(.SUB_LIST(arg: GRAR.init(offset: offset)))
        //TODO: 확인 필요
            .map { $0 }
            .asObservable()
    }
    
    public func fetchFavoriteProblem() -> Observable<State<[FavoriteProblemVO]>> {
        dbRepository
            .fetchFavoriteProblems()
            .asObservable()
            .map { .success($0) }
    }
    
    public func fetchProblemHistoryEqualStatus(status code: String) -> Observable<Result<[SubmissionVO], Error>> {
        dbRepository.fetch(.isEqualStatusCode(code))
            .asObservable()
            .map { .success($0) }
        
    }
}
