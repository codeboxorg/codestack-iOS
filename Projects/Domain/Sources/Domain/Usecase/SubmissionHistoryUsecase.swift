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
    func fetchProblemHistoryEqualStatus(status code: SolveStatus) -> Observable<Result<[SubmissionVO], Error>>
//    func deleteItem(item: SubmissionVO) -> Observable<Bool>
    func deleteItem(item: SubmissionVO) -> Completable
}

public final class DefaultHistoryUsecase: HistoryUsecase {
    
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
    
    public func fetchSubmission(offset: Int) -> Observable<[SubmissionVO]> {
        return submissionRepository
            .fetchSubmission(GRQuery(offset: offset))
            .catchAndReturn(([],.init(limit: 0, offset: 0, totalContent: 0, totalPage: 0)))
            .map { frinfo in
                frinfo.0
                // TODO: 확인 -> Page INfo VO
            }
            .asObservable()
    }
    
    public func deleteItem(item: SubmissionVO) -> Completable {
        switch item.statusCode {
        case .favorite:
            return dbRepository.removeFavor(.isEqualID(item.problem.id))
        case .temp:
            return dbRepository.remove(.is_Equal_ST_ID(item.id, item.statusCode))
        default:
            return .empty()
        }
    }
    
    public func fetchMe(name: String) -> Observable<[SubmissionVO]> {
        submissionRepository
            .fetchMeSubmissions(name)
            .map { $0 }
            .asObservable()
    }
    
    public func fetchFavoriteProblem() -> Observable<State<[FavoriteProblemVO]>> {
        dbRepository
            .fetchFavoriteProblems()
            .asObservable()
            .map { .success($0) }
    }
    
    public func fetchProblemHistoryEqualStatus(status code: SolveStatus) -> Observable<Result<[SubmissionVO], Error>> {
        dbRepository.fetch(.isEqualStatusCode(code))
            .asObservable()
            .map { .success($0) }
    }
}
