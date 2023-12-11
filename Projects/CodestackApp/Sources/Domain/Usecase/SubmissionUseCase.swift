//
//  SubmissionUsecase.swift
//  CodeStack
//
//  Created by 박형환 on 11/28/23.
//

import Foundation
import RxSwift
import RxCocoa

typealias State<T> = Result<T, Error>

protocol SubmissionUseCase: AnyObject {
    func submitSubmissionAction(model: SendProblemModel) -> Observable<State<Submission>>
    func updateSubmissionAction(model: SendProblemModel) -> Observable<Bool>
    
    func fetchProblemSubmissionHistory(id: ProblemID, state code: String) -> Observable<State<[Submission]>>
    
    // func fetchSubmissionByLanguage(name: String) -> Observable<State<[Submission]>>
    func updateFavoritProblem(model: FavoriteProblem, flag: Bool) -> Observable<State<Bool>>
    
    func fetchProblem(id: ProblemID) -> Observable<State<Problem>>
    func fetchProblemHistoryEqualStatus(status code: String) -> Observable<State<[Submission]>>
    func fetchSubmissionCalendar() -> Observable<State<SubmissionCalendar>>
}

enum SendError: Error {
    case isEqualSubmission
    case isNotStoreState
    case fetchFailProblem
    case none
}

final class DefaultSubmissionUseCase: SubmissionUseCase {
    
    private let dbRepository: DBRepository
    private let webRepository: WebRepository
    
    init(dbRepository: DBRepository,
         webRepository: WebRepository) {
        self.dbRepository = dbRepository
        self.webRepository = webRepository
    }
    
    func fetchProblem(id: ProblemID) -> Observable<Result<Problem, Error>> {
       webRepository
            .getProblemByID(query: Query.getProblemByID(id: id))
            .asObservable()
            .map { problem in .success(problem)}
            .catchAndReturn(.failure(SendError.fetchFailProblem))
    }
    
    func submitSubmissionAction(model: SendProblemModel) -> Observable<Result<Submission, Error>> {
        dbRepository.fetch(.recent(model.problemID))
            .asObservable()
            .subscribe(on: MainScheduler.instance)
            .filter { value in
                guard let recentSubmission = value.first else { return true }
                if recentSubmission.isEqualContent(other: model) { throw SendError.isEqualSubmission }
                return true
            }
            .observe(on: ConcurrentDispatchQueueScheduler.init(queue: .global()))
            .flatMap { [weak webRepository] value -> Maybe<Submission> in
                guard let webRepository else { return .empty() }
                let mutation = Mutation.problemSubmit(model: model)
                return webRepository
                    .perform(mutation: mutation, max: 2)
                    .map { result in Submission(with: result.createSubmission) }
            }
            .do(onNext: { [weak self] in self?.storeInRepo(submission: $0)  })
            .map { .success($0)}
            .catch { .just(.failure($0)) }
    }
    
    func fetchProblemSubmissionHistory(id: ProblemID, state code: String) -> Observable<Result<[Submission], Error>> {
        dbRepository.fetch(.isNotTemp(id, code))
            .asObservable()
            .map { .success($0) }
    }
    
    func fetchProblemHistoryEqualStatus(status code: String) -> Observable<Result<[Submission], Error>> {
        dbRepository.fetch(.isEqualStatusCode(code))
            .asObservable()
            .map { .success($0) }
    }
    
     
    func updateSubmissionAction(model: SendProblemModel) -> Observable<Bool> {
        // MARK: 이미 임시저장이 되어있을 경우 무시
        // 최근 기록이 같을때
        dbRepository
            .fetchProblemState()
            .asObservable()
            .flatMap { states throws -> Observable<[Submission]> in
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
                    let _submission = model.makeTempSubmission()
                    return self.dbRepository.store(submission: _submission)
                        .asObservable()
                        .map { _ in true }
                }
                
                let unWrapSubmission = submission!
                
                if !unWrapSubmission.isEqualContent(other: model) {
                    // 다른 내용일때 임시저장 업데이트
                    let _submission = model.makeTempSubmission()
                    
                    return self.updateSubmissionState(submission: _submission)
                        .asObservable()
                        .map { _ in true }
                } else {
                    // 같은 내용일때 그냥 dissmiss
                    return .just(false)
                }
            }
    }
    
    func fetchSubmissionCalendar() -> Observable<State<SubmissionCalendar>> {
        dbRepository
            .fetchSubmissionCalendar()
            .compactMap {
                if let calendar = $0.first {
                    return calendar
                } else {
                    #if DEBUG
                    return SubmissionCalendar.generateMockCalendar()
                    #else
                    return SubmissionCalendar.init(dates: [])
                    #endif
                }
            }
            .compactMap { .success($0) }
            .asObservable()
        //         _ = service?.getSubmissionDate(query: Query.getSubmissionHistory(limit: 100, offset: 0))
        //             .observe(on: MainScheduler.instance)
    }
    
    func updateFavoritProblem(model: FavoriteProblem, flag: Bool) -> Observable<State<Bool>> {
        if flag {
            return dbRepository
                .store(favoriteProblem: model)
                .asObservable()
                .map { _ -> State<Bool> in
                    return .success(true)
                }
        } else {
            return dbRepository
                .removeFavor(.isEqualID(model.problemID))
                .andThen(Observable.just(false).map { value in
                    return .success(value)
                })
        }
    }
      
    // TODO: Update 필요
    private func updateSubmissionState(submission: Submission) -> Single<Void> {
        return delete(submission: submission)
            .andThen(dbRepository.store(submission: submission))
    }
    
    private func storeInRepo(submission: Submission) {
        let _ = dbRepository.store(submission: submission)
            .subscribe(with: self, onSuccess: { vm, _ in
                Log.debug("success Store in ProblemState")
            })
    }
    
    // 제일 최근 제출 현황을 가져온다 생각하면
    // 0 == 없을때는 임시저장 시키면 되고,,,,,,
    // 1 == 존재했을때는 상태가 temp가 아닐경우에 temp로 변경 하면 될듯?
    private func saveInRepository(model: SendProblemModel, submissions: [Submission]) -> Single<Void> {
        let _submission = model.makeTempSubmission()
           
        if submissions.count == 0 {
            return store(submission: _submission)
        }
        
        if submissions.count == 1 {
            let fetchedSubmission = submissions.first!
            
            if let statusCode = fetchedSubmission.statusCode {
                
                if statusCode == "temp"  {
                    return update(submission: _submission)
                }

                if _submission.sourceCode == fetchedSubmission.sourceCode,
                   _submission.language == fetchedSubmission.language {
                    return .just(())
                } else {
                    return store(submission: _submission)
                }
            }
        }
        return .just(())
    }
    
    private func deleteTempRepo(submission: Submission) {
        guard let id = submission.problem?.id else { return }
        _ = dbRepository.fetch(.isExist(id))
            .flatMap { [weak self] fetchedSubmissions in
                guard let self else { return .just(()) }
                if fetchedSubmissions.count == 1,
                   let fetchedSubmission = fetchedSubmissions.first,
                   let statusCode = fetchedSubmission.statusCode,
                   statusCode == "temp"  {
                    return self.delete(submission: fetchedSubmission)
                        .andThen(self.store(submission: submission))
                }
                return self.store(submission: submission).asObservable().asSingle()
            }
            .subscribe(with: self, onSuccess: { useCase, _ in
                Log.debug("delete Temp Repo")
            })
    }
    
    
    private func delete(submission: Submission) -> Completable {
        if let languageName = submission.language?.name,
           let problemID = submission.problem?.id ,
           let statusCode = submission.statusCode {
            return dbRepository
                .remove(.delete(languageName, problemID, statusCode))
        }
        return .empty()
    }
    
    private func store(submission: Submission) -> Single<Void> {
        dbRepository
            .store(submission: submission)
    }
    
    private func update(submission: Submission) -> Single<Void> {
        dbRepository
            .update(submission: submission,
                    type: .update(submission.id ?? "-1",
                                  submission.problem?.id ?? ""))
    }
}

extension Submission {
    
    /// 제출 같은 language와 source코드 여부
    /// - Parameter other: 다른 제출 모델
    /// - Returns: 같은 내용인지 flag
    func isEqualContent(other: SendProblemModel) -> Bool {
        if self.sourceCode == other.sourceCode,
           self.language == other.language {
            return true
        } else {
            return false
        }
    }
}
extension Array where Element == Submission {
    
    
    /// 같은 Problem ID를 찾는 함수,
    /// 임시저장을 배열에서 일치하는 제출을 찾아서 업데이트 할때 필요한 extension 함수
    /// - Parameter model: SendProblemModel
    /// - Returns: 일치하는 Submission
    func find(model: SendProblemModel) -> Submission? {
        return self.filter { value in
            if let id = value.problem?.id ,
               id == model.problemID {
                return true
            }
            return false
        }.first
    }
}
