//
//  RestAPI.swift
//  Data
//
//  Created by 박형환 on 12/14/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import CSNetwork

public protocol RestAPI {
    func request<T>(_ endpoint: EndPoint, operation: @escaping Operation<T>) -> Maybe<T>
    func request<T>(_ api: API, operation: @escaping Operation<T>) -> Maybe<T>
    func request<T>(_ request: URLRequest, operation: @escaping Operation<T>) -> Maybe<T>    
    func reissueToken(token: RefreshToken) -> Observable<(response: HTTPURLResponse, data: Data)>
}
