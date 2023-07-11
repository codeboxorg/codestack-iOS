//
//  SecretKey.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation
import RxSwift




extension GitOAuthorization{
    
    func postHeader(with code: GitCode) -> URLRequest{
        let url = getBaseURL(provider: .github)
        
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        

        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "content-type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        
        let body = ["code" : code.code]
    
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body,
                                                             options: [.fragmentsAllowed,.prettyPrinted,.withoutEscapingSlashes])
        }catch{
            fatalError("postHeader(with token: GitToken) -> URLRequest: \(error)")
        }
        return urlRequest
    }
    
    func postHeader(with token: GitToken) -> URLRequest{
        let url = getBaseURL(provider: .github)
        
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
        component?.queryItems = [URLQueryItem(name: "client_id", value: client_id)]
        return component?.url
    }
    
}
