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
extension LoginService: CodestackAuthorization{
//    TokenAcquisitionService<RefreshToken>.GetToken
    
    func reissueToken(token: CodestackResponseToken) -> Observable<(response: HTTPURLResponse, data: Data)>{
        
        Log.debug(token.accessToken)
        Log.debug(token.refreshToken)
        
        let request = reissueHeader(with: token.refreshToken)
        
        return urlSession.rx
            .response(request: request)
    }
    
    func signUp(id: ID, password: Pwd) -> Maybe<Bool> {
        return Maybe.empty()
    }
    
    func request(name id: ID,password: Pwd) -> Maybe<CodestackResponseToken>{
        guard let request = postHeader(with: CodestackToken(id: id, password: password)) else { return .empty()}
        
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .compactMap{ [weak self] (response: HTTPURLResponse, data: Data) throws -> CodestackResponseToken? in
                return try self?.extractTokenWithStatusCode(response,data)
            }
    }
}
