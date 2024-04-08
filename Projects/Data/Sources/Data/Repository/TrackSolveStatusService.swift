////
////  TrackSolveStatus.swift
////  Data
////
////  Created by 박형환 on 4/24/24.
////  Copyright © 2024 hyeong. All rights reserved.
////
//
//import Foundation
//import RxSwift
//import Domain
//import CSNetwork
//
//
//public extension ObservableConvertibleType where Element == Error {
//    func renewToken(with service: TrackSolveStatusService) -> Observable<Void> {
//        return service.trackStatus(for: self)
//    }
//}
//
//public final class TrackSolveStatusService {
//    public var status = ReplaySubject<Result<JudgeZeroSubmissionVO, Error>>.create(bufferSize: 1)
//    private(set) var relay = PublishSubject<JudgeZeroSubmissionVO>()
//    private var disposeBag = DisposeBag()
//    private let lock = NSRecursiveLock()
//    private var getSolveStatus: () -> Observable<JudgeZeroSubmissionVO>
//    
//    public init(_ getSolveStatus: @escaping () -> Observable<JudgeZeroSubmissionVO>) {
//        self.getSolveStatus = getSolveStatus
//        var count = 0
//        let maxCount: Int = 4
//        relay
//            .withUnretained(self)
//            .flatMap { service, _ in
//                count += 1
//                if count > maxCount { throw APIError.maxRetryError }
//                return service.getSolveStatus()
//            }
//            .map { result in result.isProccessing() }
//            .bind(to: status)
//            .disposed(by: disposeBag)
//    }
//    
//    func trackStatus<O: ObservableConvertibleType>(for source: O) -> Observable<Void> where O.Element == Error {
//        let relay = self.relay
//        let lock = self.lock
//        
//        let error = source
//            .asObservable()
//            .flatMap { error in
//                
//            }
//            .filter { _ in false }
//            .map { _ in }
//        
//        return Observable.merge(status.skip(1).map { _ in }, error)
//    }
//}
