//
//  GitHubLoginManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation
import RxSwift
import RxCocoa

final class ServiceManager: NSObject{
    
    let urlSession: URLSession
    
    var disposeBag = DisposeBag()
    
    init(_ session: URLSession = URLSession(configuration: .default)) {
        self.urlSession = session
        super.init()
        
    }
}


extension ServiceManager: AppleAuthorization{
    //MARK: - codeStack APPle
    func request(with token: AppleToken) -> Maybe<String>{
        let request = postHeader(with: token)
        
        return URLSession.shared.rx
            .response(request: request)
            .asMaybe()
            .map{ (response: HTTPURLResponse, data: Data) -> String in
                if  (200..<300) ~= response.statusCode {
                    do{
                        let token = try JSONSerialization.jsonObject(with: data)
                        let resonseToken = try JSONDecoder().decode(CodestackLoginResponse.self, from: data)
                        print("token : \(token)")
                        return "성공했지;;;; -> \(resonseToken)"
                    }catch{
                        throw CSError.decodingError
                    }
                }else {
                    throw CSError.httpResponseError(code: response.statusCode)
                }
            }
    }
}

extension ServiceManager: GitOAuthorization{
    
    /// Git Login URL 오픈 -> 사파리
    func gitOAuthrization() throws{
        guard let url = makeGitURL() else { throw CSError.badURLError}
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }else{
            throw CSError.canNotOpen
        }
    }
    
    //MARK: - codestack server
    func request(with token: GitToken, provider: OAuthProvider) -> Maybe<Void>{
        let request = postHeader(with: token)
        
        return URLSession.shared.rx
            .response(request: request)
            .asMaybe()
            .map{ (response: HTTPURLResponse, data: Data) -> Void in
                if  (200..<300) ~= response.statusCode {
                    do{
                        let token = try JSONSerialization.jsonObject(with: data)
                        print("token : \(token)")
                        return ()
                    }catch{
                        throw CSError.decodingError
                    }
                }else {
                    throw CSError.httpResponseError(code: response.statusCode)
                }
            }
    }
    
    //MARK: - Git server
    func request(code: String) -> Maybe<GitToken>{
        guard let request = try? self.postGitRequest(code: code) else {return Maybe.error(CSError.badURLRequest)}
        return URLSession.shared.rx
            .response(request: request)
            .asMaybe()
            .map{ (response: HTTPURLResponse, data: Data) -> GitToken in
                if  (200..<300) ~= response.statusCode {
                    do{
                        let token = try JSONDecoder().decode(GitToken.self, from: data)
                        return token
                    }catch{
                        throw CSError.decodingError
                    }
                }else {
                    throw CSError.httpResponseError(code: response.statusCode)
                }
            }
    }
}
