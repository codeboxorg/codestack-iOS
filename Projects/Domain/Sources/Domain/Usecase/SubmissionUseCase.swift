//
//  SubmissionUsecase.swift
//  CodeStack
//
//  Created by 박형환 on 11/28/23.
//

import Foundation
import RxSwift

public protocol SubmissionUseCase: AnyObject {
    
    func submitSubmissionAction(model: SubmissionVO) -> Observable<State<SubmissionVO>>
    func updateSubmissionAction(model: SubmissionVO) -> Observable<Bool>
    
    func fetchProblemSubmissionHistory(id: ProblemID, state code: SolveStatus) -> Observable<Swift.Result<[SubmissionVO], Error>>
    
    func updateFavoritProblem(model: FavoriteProblemVO, flag: Bool) -> Observable<State<Bool>>
    func fetchIsFavorite(problemID: ProblemID) -> Observable<Bool>
    
    func fetchProblem(id: ProblemID) -> Observable<State<ProblemVO>>

    func fetchSubmissionCalendar() -> Observable<State<SubmissionCalendarVO>>
    func fetchRecent(id: ProblemID) -> Observable<SubmissionVO>
}

public protocol SubmissionGlobalOutput: AnyObject {
    var favoriteSubmission: PublishSubject<SubmissionVO> { get set }
    var deleteSUbmission: PublishSubject<SubmissionVO> { get set }
    var sendSubmission: PublishSubject<SubmissionVO> { get set }
}

public final class DefaultSubmissionUseCase: SubmissionUseCase, SubmissionGlobalOutput {
    
    private let dbRepository: DBRepository
    private let webRepository: WebRepository
    private let submissionReposiotry: SubmissionRepository
    
    public init(dbRepository: DBRepository,
                webRepository: WebRepository,
                submissionReposiotry: SubmissionRepository) {
        self.dbRepository = dbRepository
        self.webRepository = webRepository
        self.submissionReposiotry = submissionReposiotry
    }
    
    // MARK: Output
    public var favoriteSubmission = PublishSubject<SubmissionVO>()
    public var deleteSUbmission = PublishSubject<SubmissionVO>()
    public var sendSubmission = PublishSubject<SubmissionVO>()
    
    public func fetchProblem(id: ProblemID) -> Observable<State<ProblemVO>> {
        submissionReposiotry
            .fetchProblemByID(id)
            .asObservable()
            .map { problem in .success(problem)}
            .catchAndReturn(.failure(SendError.fetchFailProblem))
    }
    
    public func fetchRecent(id: ProblemID) -> Observable<SubmissionVO> {
        dbRepository
            .fetch(.isExist(id))
            .compactMap { $0.last }
            .asObservable()
    }
    
    public func submitSubmissionAction(model: SubmissionVO) -> Observable<State<SubmissionVO>> {
        dbRepository.fetch(.recent(model.problem.id, notContain: .temp))
            .asObservable()
            .subscribe(on: MainScheduler.instance)
            .map { $0.first }
            .filter { subVO in
                guard let recentSubmission = subVO else { return true }
                if recentSubmission.isEqualContent(other: model) { throw SendError.isEqualSubmission }
                return true
            }
            .observe(on: ConcurrentDispatchQueueScheduler.init(queue: .global()))
            .map { _ in model }
            .withUnretained(self)
            .flatMap { useCase, model -> Maybe<SubmissionVO> in
                useCase.submissionReposiotry
                    .performSubmit(model, max: 2)
                    .flatMap { vo in
                        useCase.dbRepository.store(submission: vo).asMaybe().map { [vo] _ in vo }
                    }
            }
            .map { .success($0) }
            .catch { [weak self] error in
                guard let self else { return .just(.failure(error)) }
                let domainError = self.webRepository.mapError(error)
                if let domainError {
                    return Observable.just(.failure(domainError))
                } else {
                    return Observable.just(.failure(error))
                }
            }
    }
    
    public func fetchProblemSubmissionHistory(id: ProblemID, state code: SolveStatus) -> Observable<Swift.Result<[SubmissionVO], Error>> {
        dbRepository.fetch(.is_NOT_ST_Equal_ID(id, code))
            .asObservable()
            .map { .success($0) }
    }
    
    public func fetchIsFavorite(problemID: ProblemID) -> Observable<Bool> {
        dbRepository
            .fetchFavoriteExist(problemID)
            .asObservable()
    }
     
    public func updateSubmissionAction(model: SubmissionVO) -> Observable<Bool> {
        dbRepository
            .fetchProblemState(.all)
            .asObservable()
            .map { $0.first }
            .flatMap { state -> Observable<[SubmissionVO]> in
                state == nil ? .just([]) : .just(state!.submissions)
            }
            .map { submissions in submissions.find(model: model) }
            .withUnretained(self)
            .flatMap { useCase, submission -> Observable<Bool> in
                
                // 내용이 없을때 임시저장
                if submission == nil {
                    return useCase.dbRepository.store(submission: model)
                        .asObservable()
                        .map { _ in true }
                }
                
                let isNotEqualContent = !submission!.isEqualContent(other: model)
                
                return isNotEqualContent ?
                useCase.updateSubmissionState(submission: model)
                    .asObservable()
                    .map { _ in true }
                :
                    .just(false)
            }
    }
    
    public func fetchSubmissionCalendar() -> Observable<State<SubmissionCalendarVO>> {
        dbRepository
            .fetchSubmissionCalendar()
            .compactMap {
                if let calendar = $0.first {
                    return calendar
                } else {
                    #if DEBUG
                    // return SubmissionCalendarVO.generateMockCalendar()
                    return SubmissionCalendarVO.init(dates: [])
                    #else
                    return SubmissionCalendarVO.init(dates: [])
                    #endif
                }
            }
            .compactMap { .success($0) }
            .asObservable()
    }
    
    
    // 이미 추가된 상태에 따라서 즉, 이미 저장되어있다면 아무것도 저장하지 않아야 함
    public func updateFavoritProblem(model: FavoriteProblemVO, flag: Bool) -> Observable<State<Bool>> {
        Observable.just((model, flag))
            .withUnretained(self)
            .flatMap { useCase, tuple in
                let (model, flag) = tuple
                return flag
                ?
                useCase
                    .fetchIsFavorite(problemID: model.problemID)
                    .filter { !$0 }
                    .flatMapFirst { _ in
                        useCase.dbRepository.store(favoriteProblem: model)
                    }
                    .map { _ -> State<Bool> in .success(true)}
                :
                useCase.dbRepository.removeFavor(.isEqualID(model.problemID))
                    .andThen(.just(false))
                    .map { value in
                        return .success(value)
                    }
            }
    }
      
    // TODO: Update 필요
    private func updateSubmissionState(submission: SubmissionVO) -> Single<Void> {
        return delete(submission: submission)
            .andThen(dbRepository.store(submission: submission))
    }
    
    private func delete(submission: SubmissionVO) -> Completable {
        let languageName = submission.language.name
        let problemID = submission.problem.id
        let statusCode = submission.statusCode
        return dbRepository
            .remove(.delete(languageName, problemID, statusCode))
    }
}

