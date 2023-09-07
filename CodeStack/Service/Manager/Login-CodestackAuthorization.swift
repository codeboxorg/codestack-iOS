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
    
    
    func editProfile(image: Data) -> Maybe<Bool> {
        guard let request = editProfileRequest(image: image) else { return Maybe.just(false) }
        
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .map { (response: HTTPURLResponse, data: Data) throws -> Bool in
                guard (200..<300) ~= response.statusCode else { return false }
                Log.debug("response statusCode: \(response.statusCode)")
                Log.debug("data: \(data)")
                return true
            }
        
    }
    
    func reissueToken(token: CodestackResponseToken) -> Observable<(response: HTTPURLResponse, data: Data)>{
        
        Log.debug(token.accessToken)
        Log.debug(token.refreshToken)
        let request = reissueURLRequest(with: token.refreshToken)
        
        return urlSession.rx
            .response(request: request)
    }
    
    func signUp(member: MemberDTO) -> Maybe<Bool> {
        guard let request = signUpRequest(member: member) else { return .empty() }
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .map { (response: HTTPURLResponse, data: Data) throws -> Bool in
                guard (200..<300) ~= response.statusCode else { return false }
                Log.debug("response statusCode: \(response.statusCode)")
                Log.debug("data: \(data)")
                return true
            }
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
