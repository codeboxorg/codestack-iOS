//
//  TestNetworkServicer.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/15.
//


import Foundation
import RxSwift



public typealias Response = (URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)>

class TestNetworkService{
    
    
    static var shared = TestNetworkService()
    
    private init(){
        
    }
    /// Builds and makes network requests using the token provided by the service. Will request a new token and retry if
    /// the result is an unauthorized (401) error.
    ///
    /// - Parameters:
    ///   - response: A function that sends requests to the network and emits responses. Can be for example
    ///               `URLSession.shared.rx.response`
    ///   - tokenAcquisitionService: The object responsible for tracking the auth token. All requests should use the same
    ///                              object.
    ///   - request: A function that can build the request when given a token.
    /// - Returns: response of a guaranteed authorized network request.
    public func getData<T>(response: @escaping Response,
                           tokenAcquisitionService: TokenAcquisitionService<T>,
                           request: @escaping (T) throws -> URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)> {
        return Observable
            .deferred {
                tokenAcquisitionService.token.take(1).compactMap { result in
                    guard case let .success(token) = result else { return nil }
                    return token
                }
            }
            .map { try request($0) }
            .flatMap { response($0) }
            .map { response in
                guard response.response.statusCode != 401 else { throw TokenAcquisitionError.unauthorized }
                return response
            }
            .retry(when: {value in value.renewToken(with: tokenAcquisitionService) })
    }
}

// MARK: -
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
    case unauthorized
    case refusedToken(response: HTTPURLResponse, data: Data)
}

public final class TokenAcquisitionService<T> {
    
    /// responds with the current token immediatly and emits a new token whenver a new one is aquired. You can, for
    /// example, subscribe to it in order to save the token as it's updated. If token acquisition fails, this will emit a
    /// `.next(.failure)` event.
    public var token: Observable<Result<T, Error>> {
        return _token.asObservable()
    }
    
    public typealias GetToken = (T) -> Observable<(response: HTTPURLResponse, data: Data)>
    
    /// Creates a `TokenAcquisitionService` object that will store the most recent authorization token acquired and will
    /// acquire new ones as needed.
    ///
    /// - Parameters:
    ///   - initialToken: The token the service should start with. Provide a token from storage or an empty/nil object
    ///                   represting a missing token, if one has not been aquired yet.
    ///   - getToken: A function responsable for aquiring new tokens when needed.
    ///   - extractToken: A function that can extract a token from the data returned by `getToken`.
    public init(initialToken: T, getToken: @escaping GetToken, extractToken: @escaping (Data) throws -> T) {
        relay
            .flatMapFirst { token in
                getToken(token)
                    .map { (urlResponse) -> Result<T, Error> in
                        guard urlResponse.response.statusCode / 100 == 2 else {
                            return .failure(TokenAcquisitionError.refusedToken(response: urlResponse.response, data: urlResponse.data))
                        }
                        return Result(catching: { try extractToken(urlResponse.data) })
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
        let lock = self.lock
        let relay = self.relay
        let error = source
            .asObservable()
            .map { error in
                guard (error as? TokenAcquisitionError) == .unauthorized else { throw error }
            }
            .flatMap { [unowned self] in self.token.take(1) }
            .do(onNext: {
                guard case let .success(token) = $0 else { return }
                lock.lock()
                relay.onNext(token)
                lock.unlock()
            })
                .filter { _ in false }
                .map { _ in }
        
        return Observable.merge(token.skip(1).map { _ in }, error)
    }
    
    private let _token = ReplaySubject<Result<T, Error>>.create(bufferSize: 1)
    private let relay = PublishSubject<T>()
    private let lock = NSRecursiveLock()
    private let disposeBag = DisposeBag()
}
