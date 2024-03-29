//
//  SubmissionUsecase.swift
//  CodeStack
//
//  Created by 박형환 on 11/28/23.
//

import Foundation
import RxSwift
import RxCocoa
import Global

public protocol SubmissionUseCase: AnyObject {
    func submitSubmissionAction(model: SubmissionVO) -> Observable<State<SubmissionVO>>
    func updateSubmissionAction(model: SubmissionVO) -> Observable<Bool>
    
    func fetchProblemSubmissionHistory(id: ProblemID, state code: String) -> Observable<State<[SubmissionVO]>>
    
    func updateFavoritProblem(model: FavoriteProblemVO, flag: Bool) -> Observable<State<Bool>>
    func fetchIsFavorite(problemID: ProblemID) -> Observable<Bool>
    
    func fetchProblem(id: ProblemID) -> Observable<State<ProblemVO>>

    func fetchSubmissionCalendar() -> Observable<State<SubmissionCalendarVO>>
}

public enum SendError: Error {
    case isEqualSubmission
    case isNotStoreState
    case fetchFailProblem
    case unowned
    case unauthorized
    case none
}


public final class DefaultSubmissionUseCase: SubmissionUseCase {
    
    private let dbRepository: DBRepository
    private let webRepository: WebRepository
    
    public init(dbRepository: DBRepository,
                webRepository: WebRepository) {
        self.dbRepository = dbRepository
        self.webRepository = webRepository
    }
    
    public func fetchProblem(id: ProblemID) -> Observable<State<ProblemVO>> {
       webRepository
            .getProblemByID(id)
            .asObservable()
            .map { problem in .success(problem)}
            .catchAndReturn(.failure(SendError.fetchFailProblem))
    }
    
    public func submitSubmissionAction(model: SubmissionVO) -> Observable<State<SubmissionVO>> {
        dbRepository.fetch(.recent(model.problem.id, notContain: "temp"))
            .asObservable()
            .subscribe(on: MainScheduler.instance)
            .map { $0.first }
            .filter { subVO in
                guard let recentSubmission = subVO else { return true }
                if recentSubmission.isEqualContent(other: model) { throw SendError.isEqualSubmission }
                return true
            }
            .observe(on: ConcurrentDispatchQueueScheduler.init(queue: .global()))
            .map { _ in model.toSubmitMut() }
            .withUnretained(self)
            .flatMap { useCase, model -> Maybe<SubmissionVO> in
                useCase.webRepository.perform(model, max: 2)
            }
            .do(onNext: { [weak self] in self?.storeInRepo(submission: $0)  })
            .map { .success($0) }
            .catch { error in .just(.failure(error)) }
    }
    
    public func fetchProblemSubmissionHistory(id: ProblemID, state code: String) -> Observable<Result<[SubmissionVO], Error>> {
        dbRepository.fetch(.is_NOT_ST_Equal_ID(id, code))
            .asObservable()
            .map { .success($0) }
    }
    
    public func fetchIsFavorite(problemID: ProblemID) -> Observable<Bool> {
        dbRepository
            .fetchFavoriteExist(.isEqualID(problemID))
            .asObservable()
    }
    
     
    public func updateSubmissionAction(model: SubmissionVO) -> Observable<Bool> {
        // MARK: 이미 임시저장이 되어있을 경우 무시
        // 최근 기록이 같을때
        dbRepository
            .fetchProblemState(.all)
            .asObservable()
            .flatMap { states throws -> Observable<[SubmissionVO]> in
                if let state = states.first {
                    return .just(state.submissions)
                } else {
                    return .just([])
                }
            }
            .flatMap { [weak self] submissions -> Observable<Bool> in
                guard let self else { return  .just(false)}
                
                let submission = submissions.find(model: model)
                
                // 내용이 없을때 임시저장
                if submissions.isEmpty || submission == nil {
                    return self.dbRepository.store(submission: model)
                        .asObservable()
                        .map { _ in true }
                }
                
                let unWrapSubmission = submission!
                
                if !unWrapSubmission.isEqualContent(other: model) {
                    // 다른 내용일때 임시저장 업데이트
                    return self.updateSubmissionState(submission: model)
                        .asObservable()
                        .map { _ in true }
                } else {
                    // 같은 내용일때 그냥 dissmiss
                    return .just(false)
                }
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
                    return SubmissionCalendarVO.generateMockCalendar()
                    #else
                    return SubmissionCalendarVO.init(dates: [])
                    #endif
                }
            }
            .compactMap { .success($0) }
            .asObservable()
        //         _ = service?.getSubmissionDate(query: Query.getSubmissionHistory(limit: 100, offset: 0))
        //             .observe(on: MainScheduler.instance)
    }
    
    
    // TODO: !!!
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
//        if flag {
//            return dbRepository
//                .store(favoriteProblem: model)
//                .asObservable()
//                .map { _ -> State<Bool> in
//                    return .success(true)
//                }
//        } else {
//            return dbRepository
//                .removeFavor(.isEqualID(model.problemID))
//                .andThen(Observable.just(false).map { value in
//                    return .success(value)
//                })
//        }
    }
      
    // TODO: Update 필요
    private func updateSubmissionState(submission: SubmissionVO) -> Single<Void> {
        return delete(submission: submission)
            .andThen(dbRepository.store(submission: submission))
    }
    
    private func storeInRepo(submission: SubmissionVO) {
        let _ = dbRepository.store(submission: submission)
            .subscribe(with: self, onSuccess: { vm, _ in
                Log.debug("success Store in ProblemState")
            })
    }
    
    // 제일 최근 제출 현황을 가져온다 생각하면
    // 0 == 없을때는 임시저장 시키면 되고,,,,,,
    // 1 == 존재했을때는 상태가 temp가 아닐경우에 temp로 변경 하면 될듯?
    private func saveInRepository(model: SubmissionVO, submissions: [SubmissionVO]) -> Single<Void> {
        let _submission = model
           
        if submissions.count == 0 {
            return store(submission: _submission)
        }
        
        if submissions.count == 1 {
            let fetchedSubmission = submissions.first!
            
            let statusCode = fetchedSubmission.statusCode
            
            if statusCode == "temp"  {
                return update(submission: _submission)
            }
            
            return store(submission: _submission)
            //                if _submission.sourceCode == fetchedSubmission.sourceCode,
            //                   _submission.language == fetchedSubmission.language {
            //                    return .just(())
            //                } else { }
            
        }
        return .just(())
    }
    
    private func deleteTempRepo(submission: SubmissionVO) {
        _ = dbRepository.fetch(.isExist(submission.problem.id))
            .flatMap { [weak self] fetchedSubmissions in
                guard let self else { return .just(()) }
                if fetchedSubmissions.count == 1,
                   let fetchedSubmission = fetchedSubmissions.first,
                   fetchedSubmission.statusCode == "temp"  {
                    return self.delete(submission: fetchedSubmission)
                        .andThen(self.store(submission: submission))
                }
                return self.store(submission: submission).asObservable().asSingle()
            }
            .subscribe(with: self, onSuccess: { useCase, _ in
                Log.debug("delete Temp Repo")
            })
    }
    
    
    private func delete(submission: SubmissionVO) -> Completable {
        let languageName = submission.language.name
        let problemID = submission.problem.id
        let statusCode = submission.statusCode
        return dbRepository
            .remove(.delete(languageName, problemID, statusCode))
    }
    
    private func store(submission: SubmissionVO) -> Single<Void> {
        dbRepository
            .store(submission: submission)
    }
    
    private func update(submission: SubmissionVO) -> Single<Void> {
        dbRepository
            .update(submission: submission,
                    type: .update(submission.id, submission.problem.id ))
    }
}

