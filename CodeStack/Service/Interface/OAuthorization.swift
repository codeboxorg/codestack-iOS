//
//  NetworkInterface.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/03.
//

import Foundation
import RxSwift

typealias OAuthrizationRequest = GitOAuthorization & AppleAuthorization & CodestackAuthorization

protocol OAuthorization{
    func authEndpoint(provider: OAuthProvider) -> String
    func getBaseURL(path: API) -> String
    
    var extractTokenWithStatusCode: (_ response: HTTPURLResponse, _ data: Data) throws -> CodestackResponseToken { get }
    var extractToken: (Data) throws -> CodestackResponseToken { get }
}


extension OAuthorization{
    private var base: String{
        guard
            let base = Bundle.main.infoDictionary?["codestack_endpoint"] as? String
        else {return "" }
        return base
    }
    
    var commonHeader: [String: String]{
        ["content-type" : "application/json; charset=utf-8",
         "accept" : "application/json"]
    }
    
    func getBaseURL(path: API) -> String{
        switch path {
        case .login:
            return base + "v1/auth/login"
        case .reissueToken:
            return base + "v1/auth/token"
        case .regitster:
            return base + "v1/auth/register"
        case .password:
            return base + "v1/auth/password"
        case .profile:
            return base + "v1/member/profile"
        case .health:
            return base + "health"
        }
    }
    
    func authEndpoint(provider: OAuthProvider) -> String{
        switch provider {
        case .email:
            return getBaseURL(path: .login) + ""
        default:
            return base + "v1/oauth2/login/" + "\(provider.rawValue)"
        }
    }
    
    var extractTokenWithStatusCode: (_ response: HTTPURLResponse, _ data: Data) throws -> CodestackResponseToken{
        { response, data in
            if  (200..<300) ~= response.statusCode {
                do{
                    return try self.extractToken(data)
                }catch{
                    throw error
                }
            }else {
                throw CSError.httpResponseError(code: response.statusCode)
            }
        }
    }
    
    var extractToken: (Data) throws -> CodestackResponseToken {
        { data in
            do{
                let token = try JSONDecoder().decode(CodestackResponseToken.self, from: data)
                return token
            }catch{
                throw CSError.decodingError
            }
        }
    }
}


protocol TestService{
    func request() -> SubmissionPagedResult
    
    func request(type: SegType.Value) -> SubmissionPagedResult
}


//MARK: TestMock 삭제예졍

class NetworkService: TestService{
    
    func request() -> SubmissionPagedResult {
        let sub = Submission.dummy()
//        let result = SubmissionPagedResult(content: sub, pageInfo: _PageInfo(totalElement: 1, totalPage: 1))
        return SubmissionPagedResult(content: [], pageInfo: .init(totalElement: 0, totalPage: 0))
    }
    
    func request(type: SegType.Value) -> SubmissionPagedResult {
        let sub = Submission.dummy(type: type)
        let result = SubmissionPagedResult(content: sub, pageInfo: _PageInfo(totalElement: 1, totalPage: 1))
        return result
    }
}
