//
//  DBRepository.swift
//  CodeStack
//
//  Created by 박형환 on 11/23/23.
//

import Foundation
import CoreData
import RxSwift
import Global
import Domain

public final class DefaultDBRepository: DBRepository {
    
    
    private var persistentStore: PersistentStore
    
    public init(persistenStore: PersistentStore = CoreDataStack(version: 1)) {
        self.persistentStore = persistenStore
    }
    
    public func fetch(_ requestType: SUB_TYPE = .default) -> Single<[SubmissionVO]> {
        Single<[SubmissionVO]>.create { [weak persistentStore] single in
            
            let fetchRequest = requestType.conditionRequest()
            fetchRequest.returnsObjectsAsFaults = false
            
            let observable = persistentStore?
                .fetch(fetchRequest , map: { value in
                    value.toDomain()
                }).subscribe { value in
                    if case let .next(result) = value {
                        switch result {
                        case .success(let datas):
                            single(.success(datas))
                        case .failure(let error):
                            single(.failure(error))
                        }
                    }
                }
            return Disposables.create { observable?.dispose() }
        }
    }
    
    public func fetchProblemState() -> Single<[ProblemSubmissionStateVO]> {
        Single<[ProblemSubmissionStateVO]>.create { [weak persistentStore] single in
            let fetchRequest = ProblemSubmissionStateMO.fetchRequest()
            let observable = persistentStore?.fetch(fetchRequest, map: { value in
//                 ProblemSubmissionState.init(managedContext: value)
                value.toDomain()
            }).subscribe(onNext: { value in
                single(value)
            })
            return Disposables.create { observable?.dispose() }
        }
    }
    
    public func fetchSubmissionCalendar() -> Single<[SubmissionCalendarVO]> {
        Single<[SubmissionCalendarVO]>.create { [weak persistentStore] single in
            let request = SubmissionCalendarMO.fetchRequest()
            let observable = persistentStore?
                .fetch(request, map: { value in
//                    SubmissionCalendar(managedContext: value)
                    value.toDomain()
                }).subscribe(onNext: { result in
                    single(result)
                })
            return Disposables.create { observable?.dispose() }
        }
    }
    
    public func fetchFavoriteProblems() -> Single<[FavoriteProblemVO]> {
        Single<[FavoriteProblemVO]>.create { [weak persistentStore] single in
            let observable = persistentStore?
                .fetch(FavoritProblemMO.fetchRequest(),
                       map: { context in
                    context.toDomain()
//                    FavoriteProblem(managedContext: context)
                })
                .subscribe(onNext: { result in
                    single(result)
                })
            return Disposables.create { observable?.dispose() }
        }
    }
    
    public func remove(_ requestType: SUB_TYPE) -> Completable {
        Completable.create { [weak persistentStore] complete in
            let request = requestType.conditionRequest()
            let observable = persistentStore?
                .remove(request: request)
                .subscribe(onNext: {
                    complete(.completed)
                },onError: { error in
                    complete(.error(error))
                })
            return Disposables.create { observable?.dispose() }
        }
    }
    
    public func removeFavor(_ requestType: FAV_TYPE) -> Completable {
        Completable.create { [weak persistentStore] complete in
            let request = requestType.conditionRequest()
            let observable = persistentStore?
                .remove(request: request)
                .subscribe(onNext: {
                    complete(.completed)
                },onError: { error in
                    complete(.error(error))
                })
            return Disposables.create { observable?.dispose() }
        }
    }
    
    public func remove() -> Single<Void> {
        Single<Void>.create { [weak persistentStore] single in
            let observable = persistentStore?.remove(request: SubmissionMO.fetchRequest())
            .subscribe { value in
                 Log.debug(value)
            }
            
            let observable2 = persistentStore?.remove(request: ProblemSubmissionStateMO.fetchRequest())
            .subscribe { value in
                 Log.debug(value)
            }
            
            return Disposables.create { 
                observable?.dispose()
                observable2?.dispose()
            }
        }
    }
    
    public func update(submission: SubmissionVO, type request: SUB_TYPE) -> Single<Void> {
        Single<Void>.create { [weak persistentStore] single in
            let observable = persistentStore?.update { context in
                let request = request.conditionRequest()
                let willUpdateSubmissionMO = try context.fetch(request)
                if let mo = willUpdateSubmissionMO.first {
                    let _ = submission.updateMO(mo: mo)
                }
            }.subscribe(onNext: { value in
                single(value)
            },onError: { error in
                single(.failure(error))
            })
            return Disposables.create { observable?.dispose() }
        }
    }
    
    public func store(submission: SubmissionVO) -> Single<Void> {
        Single<Void>.create { [weak persistentStore] single in
            let observable = persistentStore?.update { context in
                
                // TODO: Submission -> SubmissionVO
                guard let submissionMO = submission.toMO(in: context) else { return }
                
                if submission.statusCode != "temp" && submission.statusCode != "favorite" {
                    // TODO: Submission Calendar 에 Submission 관계 설정
                    // 임시저장과 즐겨찾기가 아닐경우 즉, 제출 히스토리만 관계 설정
                    let submissionCalendar = try SubmissionCalendarMO.fetchSubmissionCalendarMO(context: context)
                    submissionMO.submissionCalendar = submissionCalendar
                }
                
                let problemSubmissionState = try ProblemSubmissionStateMO.fetchSubmissionStateMO(context: context, newSubmission: submissionMO)
                submissionMO.problemSubmissionState = problemSubmissionState
                
            }.subscribe { event in
                switch event {
                case .next(_):
                    single(.success(()))
                    break
                case .error(let error):
                    single(.failure(error))
                    break
                case .completed:
                    single(.success(()))
                    break
                }
            }
            return Disposables.create { observable?.dispose() }
        }
    }
    
    public func store(favoriteProblem: FavoriteProblemVO) -> Single<Void> {
        Single<Void>.create { [weak persistentStore] complete in
            let observable = persistentStore?
                .update { context in
                    // TODO: 변경 해야됨
//                    favoriteProblem.store(in: context)
                }
                .subscribe(onNext: { _ in
                    complete(.success(()))
                },onError: { error in
                    complete(.failure(error))
                })
            return Disposables.create { observable?.dispose() }
        }
    }
    
}
