//
//  Login-AppleAuthorization.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/27.
//

import Foundation
import RxSwift
import RxCocoa

//MARK: - Apple
extension LoginService: AppleAuthorization{
    
    func oAuthComplte(token: AppleToken) {
        loginViewModel?.oAuthComplte(apple: token)
    }
    
    //MARK: - codeStack APPle
    /// Codestack으로 토큰 요청 함수
    /// - Parameter token: 애플로 부터 받은 token (Authorization code)
    /// - Returns: 발급받은 토큰 을 요청하는 Maybe
    func request(with token: AppleToken) -> Maybe<CodestackResponseToken>{
        let request = postHeader(with: token)
        
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .compactMap{ [weak self] (response: HTTPURLResponse, data: Data) throws -> CodestackResponseToken? in
                return try self?.extractTokenWithStatusCode(response,data)
            }
    }
}
