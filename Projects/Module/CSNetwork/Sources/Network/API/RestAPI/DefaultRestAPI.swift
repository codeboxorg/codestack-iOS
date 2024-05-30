//
//  AuthManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/08.
//

import Foundation
import RxSwift
import RxCocoa
import Global


public typealias ImageURL = String
public typealias Operation<T> = (_ data: Data) throws -> T?

public protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol { }


public final class DefaultRestAPI: RestAPI {
    
    let urlSession: URLSessionProtocol
    
    public var initialToken = RefreshToken(refresh: KeychainItem.currentRefreshToken)
    
    public init(session: URLSessionProtocol = URLSession(configuration: .default)) {
        self.urlSession = session
    }
    
    public func reissueToken(token: RefreshToken) -> Observable<(response: HTTPURLResponse, data: Data)> {
        let refreshToken = KeychainItem.currentRefreshToken
        
        guard
            let request = try? API.rest(.reissue(RefreshToken(refresh: refreshToken))).urlRequest()
        else {
            return Observable.error(APIError.badURLError)
        }
        return Observable<(response: HTTPURLResponse, data: Data)>.create { [weak self ] emit in
            guard let self else { return Disposables.create {}}
            let task = urlSession.dataTask(with: request, completionHandler: { data, response, err  in
                if let response, let httpResponse = response as? HTTPURLResponse,let data {
                    emit.onNext((httpResponse, data))
                    emit.onCompleted()
                } else {
                    emit.onError(APIError.fetchError(err!))
                }
            })
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
    
    public func request<T>(_ endpoint: EndPoint, operation: @escaping Operation<T>) -> Maybe<T> {
        guard let request = try? endpoint.createRequest() else { return .error(APIError.badURLError)}
        return Maybe<T>.create { [weak self ] maybe in
            guard let self else { return Disposables.create {}}
            let task = urlSession.dataTask(with: request, completionHandler: { data, response, err  in
                
                if err != nil {
                    maybe(.error(APIError.fetchError(err!)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    maybe(.error(APIError.noneHTTPResponse))
                    return
                }
                
                guard (200..<300) ~= httpResponse.statusCode else {
                    maybe(.error(APIError.httpResponseError(code: httpResponse.statusCode)))
                    return
                }
                
                guard let data else {
                    maybe(.error(APIError.emptyDataError))
                    return
                }
                
                do {
                    guard let result = try operation(data) else { throw APIError.decodingError }
                    maybe(.success(result))
                    maybe(.completed)
                } catch {
                    maybe(.error(error))
                }
            })
            task.resume()
            return Disposables.create {task.cancel() }
        }
    }
    
    public func post(_ endpoint: EndPoint) -> Completable {
        guard let request = try? endpoint.createRequest() else { return .error(APIError.badURLError)}
        return Completable.create { [weak self] complete in
            let dataTask = self?.urlSession.dataTask(with: request) { data, response, error in
                guard let response, let data else {
                    complete(.error(error ?? APIError.unKnown))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    complete(.error(APIError.noneHTTPResponse))
                    return
                }
                
                guard (200..<300) ~= httpResponse.statusCode else {
                    complete(.error(APIError.httpResponseError(code: httpResponse.statusCode)))
                    return
                }
                complete(.completed)
            }
            dataTask?.resume()
            return Disposables.create { dataTask?.cancel() }
        }
    }
    
    public func post(_ endpoint: EndPoint, operation: Operation<Void>?) -> Completable {
        guard let request = try? endpoint.createURLRequest() else { return .error(APIError.badURLError)}
        return Completable.create { [weak self] complete in
            let dataTask = self?.urlSession.dataTask(with: request) { data, response, error in
                guard let response, let data else {
                    complete(.error(error ?? APIError.unKnown))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    complete(.error(APIError.noneHTTPResponse))
                    return
                }
                
                guard (200..<300) ~= httpResponse.statusCode else {
                    complete(.error(APIError.httpResponseError(code: httpResponse.statusCode)))
                    return
                }
                
                try? operation?(data)
                
                complete(.completed)
            }
            dataTask?.resume()
            return Disposables.create { dataTask?.cancel() }
        }
    }
    
    public func request<T>(_ request: URLRequest, operation: @escaping Operation<T>) -> Maybe<T> {
        Maybe<T>.create { [weak self ] maybe in
            guard let self else { return Disposables.create {}}
            let task = urlSession.dataTask(with: request, completionHandler: { data, response, err  in
                if err != nil {
                    maybe(.error(APIError.fetchError(err!)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    maybe(.error(APIError.noneHTTPResponse))
                    return
                }
                
                guard (200..<300) ~= httpResponse.statusCode else {
                    maybe(.error(APIError.httpResponseError(code: httpResponse.statusCode)))
                    return
                }
                
                guard let data else {
                    maybe(.error(APIError.emptyDataError))
                    return
                }
                
                do {
                    guard let result = try operation(data) else { throw APIError.decodingError }
                    maybe(.success(result))
                    maybe(.completed)
                } catch {
                    maybe(.error(APIError.decodingError))
                }
            })
            task.resume()
            return Disposables.create {task.cancel() }
        }
    }
    
    public func request<T>(_ api: API, operation: @escaping Operation<T>) -> Maybe<T> {
        guard let request = try? api.urlRequest() else { return .error(APIError.badURLError) }
        return Maybe<T>.create { [weak self ] maybe in
            guard let self else { return Disposables.create {}}
            let task = urlSession.dataTask(with: request, completionHandler: { data, response, err  in
                
                if err != nil {
                    maybe(.error(APIError.fetchError(err!)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    maybe(.error(APIError.noneHTTPResponse))
                    return
                }
                
                guard (200..<300) ~= httpResponse.statusCode else {
                    maybe(.error(APIError.httpResponseError(code: httpResponse.statusCode)))
                    return
                }
                
                guard let data else {
                    maybe(.error(APIError.emptyDataError))
                    return
                }
                
                do {
                    guard let result = try operation(data) else { throw APIError.decodingError }
                    maybe(.success(result))
                    maybe(.completed)
                } catch {
                    maybe(.error(APIError.decodingError))
                }
            })
            task.resume()
            return Disposables.create {task.cancel() }
        }
    }

}
