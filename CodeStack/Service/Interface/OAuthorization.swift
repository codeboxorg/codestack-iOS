//
//  NetworkInterface.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/03.
//

import Foundation
import RxSwift

typealias OAuthrizationRequest = GitOAuthorization & AppleAuthorization & CodestackAuthorization

//POST /v1/auth/token
//body {
//    "refreshToken": {refreshToken}
//}
protocol OAuthorization{
    func getBaseURL(provider: OAuthProvider) -> String
}


extension OAuthorization{
    private var base: String{
        guard
            let base = Bundle.main.infoDictionary?["codestack_endpoint"] as? String
        else {return "" }
        return base
    }
    
    func getBaseURL(provider: OAuthProvider) -> String{
        switch provider {
        case .email:
            return base + "auth/login"
        default:
            return base + "oauth2/login/" + "\(provider.rawValue)"
        }
    }
}


protocol TestService{
    func request() -> SubmissionPagedResult
    
    func request(type: SolveStatus) -> SubmissionPagedResult
}


//MARK: TestMock 삭제예졍

class NetworkService: TestService{
    
    func request() -> SubmissionPagedResult {
        let sub = Submission.dummy()
        let result = SubmissionPagedResult(content: sub, pageInfo: _PageInfo(totalElement: 1, totalPage: 1))
        return result
    }
    
    func request(type: SolveStatus) -> SubmissionPagedResult {
        let sub = Submission.dummy(type: type)
        let result = SubmissionPagedResult(content: sub, pageInfo: _PageInfo(totalElement: 1, totalPage: 1))
        return result
    }
}
