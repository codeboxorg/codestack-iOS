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
    /// - Parameters:\
    ///   - code: github에서 받은 code
    ///   - provider: github
    /// - Returns: CodestackResponseToken
    func request(with code: GitCode, provider: OAuthProvider) -> Maybe<CodestackResponseToken>
}


extension GitOAuthorization{
    
    func postHeader(with gitcode: GitCode) -> URLRequest{
        let endpoint = authEndpoint(provider: .github)
        let url = URL(string: endpoint)!
        
        return URLRequest.request(url: url,
                                  headers: commonHeader,
                                  body: ["code" : gitcode.code],
                                  method: "POST")
    }
    
    func postHeader(with token: GitToken) -> URLRequest{
        let url = authEndpoint(provider: .github)
        
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        

        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "content-type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        
        let body = ["code" : token.accessToken]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        }catch{
            fatalError("postHeader(with token: GitToken) -> URLRequest: \(error)")
        }
        return urlRequest
    }
    
    
    
    func postGitRequest(code: String) throws -> URLRequest{
        let client_id = client_id
        let client_secret = client_secret_git
        let url = endPoint(url: gitBaseUrl + "access_token")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        urlRequest.setValue(HTTPHeaderFields.application_json.string, forHTTPHeaderField: "Accept")
        urlRequest.setValue(HTTPHeaderFields.application_json.string, forHTTPHeaderField: "Content-Type")
        
        let body = ["client_id" : client_id,
                    "client_secret" : client_secret,
                    "code" : code]
        do{
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
            return urlRequest
        }catch{
            throw CSError.JSONSerializationDataError
        }
    }
}


extension GitOAuthorization{
    
    
    var gitMobileRedirect: String{
        "https://dev.codestack.co.kr/api/oauth/github?isMobile=true"
    }
    
    var gitBaseUrl: String {
        "https://github.com/login/oauth/"
    }

    var client_id: String{
        guard
            let url = Bundle.main.infoDictionary?["client_id"] as? String
        else {
            return ""
        }
        return url
    }
    
    var client_secret_git: String{
        guard
            let url = Bundle.main.infoDictionary?["client_secret_git"] as? String
        else {
            return ""
        }
        return url
    }
    
    /// Papago API End Point
    /// - Returns: resource URL
    func endPoint(url string: String) -> URL{
        guard
            let url = URL(string: string)
        else {
            assert(false, "failed make EndPoint")
        }
        return url
    }
    

    
    func makeGitURL() -> URL?{
        var component = URLComponents(string: "https://github.com/login/oauth/authorize")
        component?.queryItems = [URLQueryItem(name: "client_id", value: client_id),
                                 URLQueryItem(name: "redirect_uri", value: "\(gitMobileRedirect)")]

        return component?.url
    }
    
}
