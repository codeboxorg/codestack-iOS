//
//  Login-GitAuthorization.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/27.
//

import UIKit
import RxSwift
import RxCocoa

//MARK: - Git
extension LoginService: GitAuth {
    
    /// LoginViewModel에 인증완료 이벤트 전달
    /// - Parameter code: github code
    public func gitOAuthComplete(code: String){
        // TODO: LoginVIewModel 제거
//        loginViewModel?.oAuthComplete(code: code)
    }
    
    /// Git Login URL 오픈 -> 사파리
    public func gitOAuthrization() throws{
        guard let url = makeGitURL() else { throw APIError.badURLError}
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }else{
            throw APIError.canNotOpen
        }
    }
    
    //MARK: - codestack server
    /// codestack server
    /// - Parameters:
    ///   - code: Git 허브 에서 받은 authorization code 이다.
    ///   - provider: github
    /// - Returns: GitHub 인증으로 부터 받은 값을 서버로 http 전송 해서 (token,refresh) 받기,발급받은 토큰 을 요청하는 Maybe
    public func request(with code: GitCode) -> Maybe<CSTokenDTO>{
        guard
            let request = try? API.rest(.auth(.github(code))).urlRequest()
        else {
            return Maybe.error(APIError.badURLError)
        }
        
        return urlSession.rx
            .response(request: request)
            .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .compactMap{ (response: HTTPURLResponse, data: Data) throws -> CSTokenDTO? in
                return try API.extractTokenWithStatusCode(response,data)
            }
    }
    
    
    //MARK: - Git server
    /// Git Auth
    /// not using  지금 이 코드는 깃허브에서 토큰을 요청해 github api 접근 권한을 가져오는 코드
    /// - Parameter code: 코드
    /// - Returns: github 서버로 부터 받은 토큰정보,  토큰 을 요청하는 Maybe
    public func request(git serverCode: String) -> Maybe<GitTokenDTO>{
        guard let request = try? self.postGitRequest(code: serverCode) else {return Maybe.error(APIError.badURLRequest)}
        return URLSession.shared.rx
            .response(request: request)
            .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asMaybe()
            .map{ (response: HTTPURLResponse, data: Data) -> GitTokenDTO in
                if  (200..<300) ~= response.statusCode {
                    do{
                        let token = try JSONDecoder().decode(GitTokenDTO.self, from: data)
                        return token
                    }catch{
                        throw APIError.decodingError
                    }
                }else {
                    throw APIError.httpResponseError(code: response.statusCode)
                }
            }
    }
}
