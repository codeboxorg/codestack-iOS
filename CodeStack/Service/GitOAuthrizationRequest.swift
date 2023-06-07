//
//  SecretKey.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation
import RxSwift


enum OAuthProvider: String{
    case github
    case apple
}

protocol OAuthrization{
    func getBaseURL(provider: OAuthProvider) -> String
}

extension OAuthrization{
    private var root: String{
        return "http://dev-api.codestack.co.kr/v1/oauth2/login/provider/"
    }
    
    func getBaseURL(provider: OAuthProvider) -> String{
        return root + "github"
    }
    
    func postHeader(with token: GitToken) -> URLRequest{
        let url = getBaseURL(provider: .github)
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        
        let body = ["type" : "access_token", "token" : token.accessToken]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        }catch{
            fatalError("postHeader(with token: GitToken) -> URLRequest: \(error)")
        }
        return urlRequest
    }
}

protocol GitOAuthrizationRequest: AnyObject{
    func gitOAuthrization() throws
    func request(code: String) -> Maybe<GitToken>
    func request(with token: GitToken, provider: OAuthProvider) -> Maybe<Void>
    func endPoint(url string: String) -> URL
}

extension GitOAuthrizationRequest{
    
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
        var component = URLComponents(string: gitBaseUrl + "authorize")
        let scope = "repo,user"
        component?.queryItems = [URLQueryItem(name: "client_id", value: client_id),
                                URLQueryItem(name: "scope", value: scope)]
        return component?.url
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
