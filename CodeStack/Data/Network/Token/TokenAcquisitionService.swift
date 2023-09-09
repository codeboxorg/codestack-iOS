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
    func renewToken<T>(with service: TokenAcquisitionService<T>) -> Observable<Void> {
        return service.trackErrors(for: self)
    }
}


final class TokenManager {
    var token: ReissueAccessToken
    
    static let shared = TokenManager()
    
    private init() {
        token = ReissueAccessToken(accessToken: KeychainItem.currentAccessToken)
    }
    
    func setToken(token: ReissueAccessToken) {
        self.token = token
    }
}

//TODO: Codestack Response Token을 token Obaservable stream에 저장하면 RefreshToken 이 메모리상에 올라가게됨
// 제네릭 타입을 변경해야함
final class TokenAcquisitionService<T> {
    
    /// responds with the current token immediatly and emits a new token whenver a new one is aquired. You can, for
    /// example, subscribe to it in order to save the token as it's updated. If token acquisition fails, this will emit a
    /// `.next(.failure)` event.
    var token: Observable<Result<T, Error>> {
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
    init(initialToken: T,
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
                            
                            if count > maxCount {
                                return .failure(TokenAcquisitionError.refusedToken(response: urlResponse.response, data: urlResponse.data))
                            }
                        
                            let result = Result(catching: { try extractToken(urlResponse.data) })
                            
                            if case let .success(data) = result,
                               let token = data as? ReissueAccessToken{
                                do {
                                   try KeychainItem.saveAccessToken(access: token)
                                } catch {
                                    throw error
                                }
                            }
                            return result
                        default:
                            return count < maxCount ? .success(token) : .failure(TokenAcquisitionError.refusedToken(response: urlResponse.response, data: urlResponse.data))
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
        let lock = self.lock
        let relay = self.relay
        let error = source
            .asObservable()
            .map { error in
                Log.error("trackErrors Map \(error)")
                if let err = error as? ApolloError {
                    switch err{
                    case .gqlErrors(let graphError):
                        Log.error("error \(err)")
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
                guard case let .success(token) = $0 else { throw TokenAcquisitionError.unauthorized }
                lock.lock()
                relay.onNext(token)
                lock.unlock()
            })
            .filter { _ in false }
            .map { _ in }
        
        Log.error("trackErrors \(error)")
        
        return Observable.merge(token.skip(1).map { _ in }, error)
    }
}
