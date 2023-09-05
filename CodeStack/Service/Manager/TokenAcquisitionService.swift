//
//  TestNetworkServicer.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/15.
//


import Foundation
import RxSwift

extension ObservableConvertibleType where Element == Error {
    
    /// Monitors self for `.unauthorized` error events and passes all other errors on. When an `.unauthorized` error is
    /// seen, the `service` will get a new token and emit a signal that it's safe to retry the request.
    ///
    /// - Parameter service: A `TokenAcquisitionService` object that is being used to store the auth token for the request.
    /// - Returns: A trigger that will emit when it's safe to retry the request.
    public func renewToken<T>(with service: TokenAcquisitionService<T>) -> Observable<Void> {
        return service.trackErrors(for: self)
    }
}

/// Errors recognized by the `TokenAcquisitionService`.
///
/// - unauthorized: It listens for and activates when it receives an `.unauthorized` error.
/// - refusedToken: It emits a `.refusedToken` error if the `getToken` request fails.
public enum TokenAcquisitionError: Error, Equatable {
    case undefinedURL
    case unauthorized
    case unowned
    case undefined
    case refusedToken(response: HTTPURLResponse, data: Data)
}


public final class TokenAcquisitionService<T> {
    
    /// responds with the current token immediatly and emits a new token whenver a new one is aquired. You can, for
    /// example, subscribe to it in order to save the token as it's updated. If token acquisition fails, this will emit a
    /// `.next(.failure)` event.
    public var token: Observable<Result<T, Error>> {
        return _token.asObservable()
    }
    
    private let _token = ReplaySubject<Result<T, Error>>.create(bufferSize: 1)
    private let relay = PublishSubject<T>()
    private let lock = NSRecursiveLock()
    private let disposeBag = DisposeBag()
    

    public typealias GetToken = (T) -> Observable<(response: HTTPURLResponse, data: Data)>
    /// Creates a `TokenAcquisitionService` object that will store the most recent authorization token acquired and will
    /// acquire new ones as needed.
    ///
    /// - Parameters:
    ///   - initialToken: The token the service should start with. Provide a token from storage or an empty/nil object
    ///                   represting a missing token, if one has not been aquired yet.
    ///   - getToken: A function responsable for aquiring new tokens when needed.
    ///   - extractToken: A function that can extract a token from the data returned by `getToken`.
    public init(initialToken: T,
                getToken: @escaping GetToken,
                max retry: Int = 2,
                extractToken: @escaping (Data) throws -> T) {
        
        let maxCount = retry
        var count: Int = 0
        
        relay
            .flatMapFirst { token in
                getToken(token)
                    .map { (urlResponse) -> Result<T, Error> in
                        count += 1
                        switch urlResponse.response.statusCode{
                        case (200..<299):
                            return Result(catching: { try extractToken(urlResponse.data) })
                        case (400..<499):
                            return .failure(TokenAcquisitionError.refusedToken(response: urlResponse.response, data: urlResponse.data))
                        case (500..<599):
                            return count < maxCount ? .success(token) : .failure(TokenAcquisitionError.refusedToken(response: urlResponse.response, data: urlResponse.data))
                        default:
                            return .failure(TokenAcquisitionError.refusedToken(response: urlResponse.response, data: urlResponse.data))
                        }
                    }
                    .catch { Observable.just(Result.failure($0)) }
            }
            .startWith(.success(initialToken))
            .subscribe(_token)
            .disposed(by: disposeBag)
    }
    
    /// Allows the token to be set imperativly if necessary.
    /// - Parameter token: The new token the service should use. It will immediatly be emitted to any subscribers to the
    ///                    service.
    func setToken(_ token: T) {
        lock.lock()
        _token.onNext(.success(token))
        lock.unlock()
    }
    
    /// Monitors the source for `.unauthorized` error events and passes all other errors on. When an `.unauthorized` error
    /// is seen, `self` will get a new token and emit a signal that it's safe to retry the request.
    ///
    /// - Parameter source: An `Observable` (or like type) that emits errors.
    /// - Returns: A trigger that will emit when it's safe to retry the request.
    func trackErrors<O: ObservableConvertibleType>(for source: O) -> Observable<Void> where O.Element == Error {
        Log.debug(self)
        Log.debug(source)
        let lock = self.lock
        let relay = self.relay
        let error = source
            .asObservable()
            .map { error in
                if let err = error as? ApolloError{
                    switch err{
                    case .gqlErrors(let graphError):
                        let flag = graphError.contains(where: { err in return err.message == "Unauthorized"})
                        if flag{
                            // Unauthorized 일때 토큰 재발급 처리 , 재발급이 블가능하면
                            return
                        }else{
                            throw TokenAcquisitionError.unowned
                        }
                    }
                }
                throw TokenAcquisitionError.unowned
            }
            .flatMap { [unowned self] in self.token.take(1) }
            .do(onNext: {
                Log.debug($0)
                guard case let .success(token) = $0 else { throw TokenAcquisitionError.unauthorized }
                lock.lock()
                Log.debug("relay: \(token)")
                relay.onNext(token)
                lock.unlock()
            })
                .filter { _ in false }
                .map { _ in }
        
        return Observable.merge(token.skip(1).map { _ in }, error)
    }
}
