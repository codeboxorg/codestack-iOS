//
//  GitHubLoginManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginService: NSObject{
    
    let urlSession: URLSession
    
    var loginViewModel: (any LoginViewModelProtocol)?
    
    var disposeBag = DisposeBag()
    
    init(_ session: URLSession = URLSession(configuration: .default)) {
        self.urlSession = session
        super.init()
        
    }
}

//MARK: - Codestack login
extension LoginService: CodestackAuthorization{
    func request(name id: ID,password: Pwd) -> Maybe<CodestackResponseToken>{
        let request = postHeader(with: CodestackToken(id: id, password: password))
        
        return URLSession.shared.rx
            .response(request: request)
            .asMaybe()
            .map{ (response: HTTPURLResponse, data: Data) -> CodestackResponseToken in
                if  (200..<300) ~= response.statusCode {
                    do{
                        let token = try JSONDecoder().decode(CodestackResponseToken.self, from: data)
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



//MARK: - Apple
extension LoginService: AppleAuthorization{
    
    func oAuthComplte(token: AppleToken) {
        loginViewModel?.oAuthComplte(apple: token)
    }
    
    //MARK: - codeStack APPle
    /// Codestack으로 토큰 요청 함수
    /// - Parameter token: 애플로 부터 받은 token (Authorization code)
    /// - Returns: 발급받은 토큰 을 요청하는 Maybe
    func request(with token: AppleToken) -> Maybe<CodestackResponseToken>{
        let request = postHeader(with: token)
        
        return URLSession.shared.rx
            .response(request: request)
            .asMaybe()
            .map{ (response: HTTPURLResponse, data: Data) -> CodestackResponseToken in
                if  (200..<300) ~= response.statusCode {
                    do{
                        let token = try JSONSerialization.jsonObject(with: data)
                        let resonseToken = try JSONDecoder().decode(CodestackResponseToken.self, from: data)
                        print("token : \(token)")
                        return resonseToken
                    }catch{
                        throw CSError.decodingError
                    }
                }else {
                    throw CSError.httpResponseError(code: response.statusCode)
                }
            }
    }
}

//MARK: - Git
extension LoginService: GitOAuthorization{
    
    
    /// LoginViewModel에 인증완료 이벤트 전달
    /// - Parameter code: github code
    func gitOAuthComplete(code: String){
        loginViewModel?.oAuthComplete(code: code)
    }
    
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
    /// codestack server
    /// - Parameters:
    ///   - code: Git 허브 에서 받은 authorization code 이다.
    ///   - provider: github
    /// - Returns: GitHub 인증으로 부터 받은 값을 서버로 http 전송 해서 (token,refresh) 받기,발급받은 토큰 을 요청하는 Maybe
    func request(with code: GitCode, provider: OAuthProvider) -> Maybe<CodestackResponseToken>{
        let request = postHeader(with: code)
        
        return URLSession.shared.rx
            .response(request: request)
            .asMaybe()
            .map{ (response: HTTPURLResponse, data: Data) -> CodestackResponseToken in
                if  (200..<300) ~= response.statusCode {
                    do{
                        print(data)
                        let json = try JSONSerialization.jsonObject(with: data)
                        
                        return .init(refreshToken: "", accessToken: "", expiresIn: 0, tokenType: "")
                    }catch{
                        throw CSError.decodingError
                    }
                }else {
                    throw CSError.httpResponseError(code: response.statusCode)
                }
            }
    }
    
    
    //MARK: - Git server
    /// Git Auth
    /// not using  지금 이 코드는 깃허브에서 토큰을 요청해 github api 접근 권한을 가져오는 코드
    /// - Parameter code: 코드
    /// - Returns: github 서버로 부터 받은 토큰정보,  토큰 을 요청하는 Maybe
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
