//
//  GitAuthorization.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/04.
//

import Foundation
import RxSwift

protocol GitOAuthorization: AnyObject,OAuthorization{
    func gitOAuthrization() throws
    func gitOAuthComplete(code: String)
    func request(code: String) -> Maybe<GitToken>
    
    /// codestack 서버에 토큰 요청하는 함수
    /// - Parameters:
    ///   - code: github에서 받은 code
    ///   - provider: github
    /// - Returns: CodestackResponseToken
    func request(with code: GitCode, provider: OAuthProvider) -> Maybe<CodestackResponseToken>
    
    
    func endPoint(url string: String) -> URL
}
