//
//  NetworkInterface.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/03.
//

import Foundation
import RxSwift

public typealias Auth = GitAuth & AppleAuth & CSAuth

public protocol GitAuth: AnyObject {
    func gitOAuthrization() throws
    func gitOAuthComplete(code: String)
    
    func request(git serverCode: String) -> Maybe<GitTokenDTO>
    func request(with code: GitCode) -> Maybe<CSTokenDTO>
}

public protocol AppleAuth: AnyObject{
    func request(with token: AppleDTO) -> Maybe<CSTokenDTO>
    func oAuthComplte(token: AppleDTO)
}

public protocol CSAuth {
    func request(name id: String, password: Pwd) -> Maybe<CSTokenDTO>
}


extension GitAuth {
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
            throw APIError.JSONSerializationDataError
        }
    }
    
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
    func endPoint(url string: String) -> URL {
        guard
            let url = URL(string: string)
        else {
            #if DEBUG
            assert(false, "failed make EndPoint")
            #endif
            fatalError("fail")
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
