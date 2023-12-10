//
//  CodestackAuthService.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/27.
//

import Foundation
import RxSwift
import RxCocoa

//MARK: - Codestack login
extension LoginService: CodestackAuthorization {
    
    func request(name id: ID,password: Pwd) -> Maybe<CodestackResponseToken> {

        guard
            let request = try? API.auth(.email(CodestackIDPwd(id: id, password: password))).urlRequest()
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
