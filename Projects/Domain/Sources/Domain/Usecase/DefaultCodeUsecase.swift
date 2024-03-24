//
//  CodeUsecase.swift
//  Domain
//
//  Created by 박형환 on 2/29/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public protocol CodeUsecase: AnyObject {
    /// OUTPUT
    var myCodestackList: BehaviorRelay<[CodestackVO]> { get set }
    
    /// INPUT
    var acceptCodeUpdate: PublishSubject<CodestackVO> { get set }
    var acceptCodeSave: PublishSubject<CodestackVO> { get set }
    
    func saveCode(model: CodestackVO) -> Observable<State<Void>>
    
    /// Code Save Action
    /// - Parameters:
    ///   - id: Code 의 ID
    ///   - codestackVO: 저장할 value object
    /// - Returns: 특정 id에 해당하는 코드가 존재하면 Update Action, 존재하지 않으면 Save Action
    func codeSaveAction(id: String, codestackVO: CodestackVO) -> Observable<State<CodestackVO>>
    
    
    func deleteCode(index: Int) -> Observable<State<Void>>
    func deleteCode(id: String) -> Observable<State<Void>>
    
    func updateCode(id: String, codestackVO: CodestackVO) -> Observable<State<Void>>
    
    func fetchCodeList() -> Observable<State<[CodestackVO]>>
    func fetchCode(id: String) -> Observable<State<CodestackVO>>
    func fetchCodeList(lanugage: LanguageVO) -> Observable<State<[CodestackVO]>>
}

public enum CodestackError: Error {
    case fetchFail
    case saveFail
    case deleteFail
    case isNotExist
}

public final class DefaultCodeUsecase: CodeUsecase {
    
    private let dbRepository: DBRepository
    
    public var myCodestackList = BehaviorRelay<[CodestackVO]>(value: [])
    public var acceptCodeUpdate = PublishSubject<CodestackVO>()
    public var acceptCodeSave = PublishSubject<CodestackVO>()
    public var acceptDeleteCode = PublishSubject<CodestackVO>()
    
    private var disposeBag = DisposeBag()
    
    public init(dbRepository: DBRepository) {
        self.dbRepository = dbRepository
        excute()
    }
    
    func excute() {
        self.acceptCodeSave
            .withLatestFrom(myCodestackList) { value, list in [value] + list }
            .subscribe(with: self, onNext: { usecase, list in
                usecase.myCodestackList.accept(list)
            })
            .disposed(by: disposeBag)
        
        self.acceptCodeUpdate
            .withLatestFrom(myCodestackList) { value, list in
                list.map { vo in vo.id == value.id ? value : vo }
                    .sortByUpdatedAt()
            }.subscribe(with: self, onNext: { usecase, list in
                usecase.myCodestackList.accept(list)
            })
            .disposed(by: disposeBag)
        
        self.acceptDeleteCode
            .withLatestFrom(myCodestackList) { value, list in
                list.filter { $0.id != value.id }
            }.subscribe(with: self, onNext: { usecase, list in
                usecase.myCodestackList.accept(list)
            })
            .disposed(by: disposeBag)
    }
    
    public func deleteCode(index: Int) -> Observable<State<Void>> {
        myCodestackList.take(1)
            .map { $0[index] }
            .withUnretained(self)
            .flatMapFirst { usecase , model in
                usecase.deleteCode(id: model.id)
                    .do(onNext: { _ in
                        usecase.acceptDeleteCode.onNext(model)
                    })
            }
    }
    
    public func deleteCode(id: String) -> Observable<State<Void>> {
        dbRepository
            .removeCodestack(id: id)
            .andThen(Observable.just(.success(())))
            .catchAndReturn(.failure(CodestackError.deleteFail))
    }
    
    public func codeSaveAction(id: String, codestackVO: CodestackVO) -> Observable<State<CodestackVO>> {
        fetchCode(id: id)
            .withUnretained(self)
            .flatMap { usecase, result -> Observable<State<Void>> in
                switch result {
                case .success:
                    return usecase.updateCode(id: id, codestackVO: codestackVO)
                        .do(onNext: { _ in
                            usecase.acceptCodeUpdate.onNext(codestackVO)
                        })
                case .failure:
                    return usecase.saveCode(model: codestackVO)
                        .do(onNext: { _ in
                            usecase.acceptCodeSave.onNext(codestackVO)
                        })
                }
            }
            .map { _ in .success(codestackVO)}
    }
    
    public func updateCode(id: String, codestackVO: CodestackVO) -> Observable<State<Void>> {
        return deleteCode(id: id)
            .withUnretained(self)
            .flatMap { usecase, _ in
                usecase.saveCode(model: codestackVO)
            }
    }
    
    public func fetchCodeList() -> Observable<State<[CodestackVO]>> {
        dbRepository
            .fetchCodestackList()
            .asObservable()
            .map { .success($0) }
            .catchAndReturn(.failure(CodestackError.fetchFail))
    }
    
    public func fetchCode(id: String) -> Observable<State<CodestackVO>> {
        dbRepository
            .fetchCodestack(id: id)
            .asObservable()
            .map { .success($0) }
            .catchAndReturn(.failure(CodestackError.fetchFail))
    }
    
    public func fetchCodeList(lanugage: LanguageVO) -> Observable<State<[CodestackVO]>> {
        dbRepository
            .fetchCodestackEqual(language: lanugage)
            .asObservable()
            .map { .success($0) }
            .catchAndReturn(.failure(CodestackError.fetchFail))
    }
    
    public func saveCode(model: CodestackVO) -> Observable<State<Void>> {
        dbRepository
            .store(codestackVO: model)
            .asObservable()
            .map { _ in .success(()) }
            .catchAndReturn(.failure(CodestackError.saveFail))
    }
    
}

extension Array where Element == CodestackVO {
    public func sortByUpdatedAt() -> Self {
        self.sorted { first, second in
            if let first = first.updatedAt.toDateKST(),
               let second = second.updatedAt.toDateKST() {
                return first < second
            } else {
                return false
            }
        }
    }
}
