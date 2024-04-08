//
//  TrackError.swift
//  Domain
//
//  Created by 박형환 on 3/2/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import Domain
import CSNetwork

public extension ObservableConvertibleType where Element == Error {
    func renewToken(with service: TrackService) -> Observable<Void> {
        return service.trackErrors(for: self)
    }
}

public final class TrackService {
    
    public var token = ReplaySubject<Result<String, Error>>.create(bufferSize: 1)
    private(set) var relay = PublishSubject<String>()
    private var disposeBag = DisposeBag()
    private let lock = NSRecursiveLock()
    private var getIdToken: () -> Completable
    
    public init(_ getIdToken: @escaping () -> Completable) {
        let maxCount = 3
        var count: Int = 0
        self.getIdToken = getIdToken
        token.onNext(.success(KeychainItem.currentFBIdToken))
        
        relay
            .withUnretained(self)
            .flatMap { service, _ in
                count += 1
                if count > maxCount { throw APIError.maxRetryError }
                return service.getIdToken()
                    .andThen(Observable.just(.success(KeychainItem.currentFBIdToken)))
                    .catch { Observable.just(Result<String, Error>.failure($0)) }
            }
            .map { result in print("token: \(result)"); return result}
            .bind(to: token)
            .disposed(by: disposeBag)
    }
    
    func trackErrors<O: ObservableConvertibleType>(for source: O) -> Observable<Void> where O.Element == Error {
        let relay = self.relay
        let lock = self.lock
        let error = source
            .asObservable()
            .map { error in
                if let err = error as? APIError,
                   case let .httpResponseError(code: code) = err ,
                   code == 401
                {
                    return ()
                }
                throw error
            }
            .flatMap { [unowned self] in self.token.take(1) }
            .do(onNext: {
                guard case let .success(token) = $0 else { throw AuthFIRError.unknown }
                lock.lock()
                relay.onNext(token)
                lock.unlock()
            })
            .filter { _ in false }
            .map { _ in }
        
        return Observable.merge(token.skip(1).map { _ in }, error)
    }
}
