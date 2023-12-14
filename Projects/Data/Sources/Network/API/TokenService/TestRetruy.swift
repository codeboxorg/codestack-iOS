//
//  TestRetruy.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/15.
//

import Foundation
import RxSwift


enum TError: Error{
    
    case testerr
    case noneError
    case newError
    case relayError
    case underError
}


public typealias TestC = (Int) -> Observable<(response: Int, data: Int)>
class ServiceTest{
    public func getData(response: @escaping TestC,
                           tokenAcquisitionService: TestRetry,
                           request: @escaping (Int) throws -> Int) -> Observable<(response: Int, data: Int)> {
        return Observable
            .deferred {
                tokenAcquisitionService.token.take(1).compactMap { result in
                    
                    guard case let .success(value) = result else { return nil }
                    return value
                }
            }
            .map {va in try request(va) }
            .flatMap { response($0) }
            .map { response in
                response
            }
            .retry(when: {value in value.reToken(service: tokenAcquisitionService) })
    }
}
public class TestRetry{
    
    var token: Observable<Result<Int,Error>>{
        _token.asObservable()
    }
    
    
    var lock = NSLock()
    var _token = ReplaySubject<Result<Int, Error>>.create(bufferSize: 1)
    private let relay = PublishSubject<Int>()
    
    var initialTokens: Int = 250
    var disposeBag = DisposeBag()
    
    private var extractToken: (Int) throws -> Int = { value in
        if value <= 200{
            throw TError.underError
        }
        return value
    }
    
    var getValidValue: (Int) -> Observable<(valid: Int,flag: Int)> = { value in
        if value < 200{
            return Observable.just(( 220, 231))
        }
        return Observable.just((value,value))
    }
    
    init(flag: Int){
        let extractToken = extractToken
        let getValidValue = getValidValue
        relay
            .flatMapFirst { token in
                
                getValidValue(token)
                    .map { (response) -> Result<Int, Error> in
                        guard response.valid / 100 == 2 else {
                            return .failure(TError.relayError)
                        }
                        return Result(catching: { try extractToken(response.valid) })
                    }
                    .catch { Observable.just(Result.failure($0)) }
            }
            .startWith(.success(initialTokens))
            .subscribe(_token)
            .disposed(by: disposeBag)
    }
    
    func trackErrors<O: ObservableConvertibleType>(for source: O) -> Observable<Void> where O.Element == Error {
        let relay = self.relay
        let lock = lock
        let error
        =
        source.asObservable()
            .map{ err in
                guard (err as? TError) == .testerr else { throw err}
            }
            .flatMap{ [unowned self] _ in self.token.take(1) }
            .do(onNext: {
                guard case let .success(token) = $0 else { return }
                lock.lock()
                relay.onNext(token)
                lock.unlock()
            })
            .filter{ _ in false}
            .map{ _ in }
        
        return Observable.merge(token.skip(1).map { _ in }, error)
    }
}

extension ObservableConvertibleType where Element == Error {
    
    /// Monitors self for `.unauthorized` error events and passes all other errors on. When an `.unauthorized` error is
    /// seen, the `service` will get a new token and emit a signal that it's safe to retry the request.
    ///
    /// - Parameter service: A `TokenAcquisitionService` object that is being used to store the auth token for the request.
    /// - Returns: A trigger that will emit when it's safe to retry the request.
    public func reToken(service: TestRetry) -> Observable<Void> {
        return service.trackErrors(for: self)
    }
}
