//
//  NetworkInterface.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/03.
//

import Foundation
import RxSwift

typealias OAuthrizationRequest = GitOAuthrizationRequest & OAuthorization

protocol AppleAuth: AnyObject{
    func request(with token: AppleToken) -> Maybe<String>
}

protocol GitOAuthrizationRequest: AnyObject{
    func gitOAuthrization() throws
    func request(code: String) -> Maybe<GitToken>
    func request(with token: GitToken, provider: OAuthProvider) -> Maybe<Void>
    func endPoint(url string: String) -> URL
}

protocol OAuthorization{
    func getBaseURL(provider: OAuthProvider) -> String
}
au·thor·i·za·tion

protocol CodestackAuthorization{
    
}



protocol ApolloService{
    func request() -> SubmissionPagedResult
}


//MARK: TestMock 삭제예졍

class NetworkService: ApolloService{
    
    func request() -> SubmissionPagedResult {
        let sub = Submission.dummy()
        let result = SubmissionPagedResult(content: sub, pageInfo: PageInfo(totalElement: 1, totalPage: 1))
        return result
    }
}
