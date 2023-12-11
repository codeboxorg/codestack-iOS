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
        
        guard
            let request = try? API.auth(.apple(token)).urlRequest()
        else {
            return Maybe.error(APIError.badURLError)
        }
        
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .compactMap{ (response: HTTPURLResponse, data: Data) throws -> CodestackResponseToken? in
                return try API.extractTokenWithStatusCode(response,data)
            }
    }
}
