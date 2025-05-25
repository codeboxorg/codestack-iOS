//
//  CodestackAuthService.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/27.
//

import Foundation
import RxSwift
import Global

//MARK: - Codestack login
extension LoginService: CSAuth {
    
    public func request(name id: String, password: Pwd) -> Maybe<CSTokenDTO> {
        guard
            let request = try? API.rest(.auth(.email(CSDTO(id: id, password: password)))).urlRequest()
        else {
            return Maybe.error(APIError.badURLError)
        }
        
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .compactMap{ (response: HTTPURLResponse, data: Data) throws -> CSTokenDTO? in
                return try API.extractTokenWithStatusCode(response,data)
            }
            .asMaybe()
    }
}
