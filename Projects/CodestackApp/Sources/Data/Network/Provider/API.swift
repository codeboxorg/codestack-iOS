//
//  API.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/08.
//

import Foundation

typealias Token = String
typealias RefreshToken = String
typealias GitCode = String
typealias ID = String
typealias ProblemID = String
typealias SubmissionID = String
typealias Pwd = String
typealias NewPwd = String
typealias ImageData = Data

enum OAuthProvider {
    case github(GitCode)
    case apple(AppleToken)
    case email(CodestackIDPwd)
    
    var value: String {
        switch self {
        case .github:
            return "github"
        case .apple:
            return "apple"
        case .email:
            return "email"
        }
    }
    
    func makeBody() -> [String : String] {
        switch self {
        case .github(let gitCode):
            return ["code" : gitCode]
        case .apple(let appleToken):
            if let _ = appleToken.user {
                return [ "code" : appleToken.authorizationCode]
            }else{
                return [ "code" : appleToken.authorizationCode]
            }
        case .email(let idpwd):
            return ["email" : idpwd.id,
                    "password" : idpwd.password]
        }
    }
}

enum API {
    case reissue(RefreshToken)
    case regitster(MemberDTO)
    case password(Pwd,NewPwd)
    case profile(ImageData)
    case health
    case auth(OAuthProvider)
}

//MARK: Property
extension API {
    
    var base: String {
        guard let base = Bundle.main.infoDictionary?["codestack_endpoint"] as? String else { return "" }
        return base
    }
    
    var commonHeader: [String: String] {
        [ "content-type" : "application/json; charset=utf-8",
          "accept" : "application/json" ]
    }
}

//MARK: Function
extension API {
    
    func getBaseURL(path: API) -> String{
        switch path {
        case .reissue:
            return base + "v1/auth/token"
        case .regitster:
            return base + "v1/auth/register"
        case .password:
            return base + "v1/auth/password"
        case .profile:
            return base + "v1/member/profile"
        case .health:
            return base + "health"
        case .auth(let provider):
            return authEndpoint(provider: provider)
        }
    }
    
    private func authEndpoint(provider: OAuthProvider) -> String{
        switch provider {
        case .email:
            return base + "v1/auth/login"
        default:
            return base + "v1/oauth2/login/" + "\(provider.value)"
        }
    }
}



//MARK: CodeStackToken Decoding closure
extension API {
    
    typealias ExtractClosure<T> = (Data) throws -> T
    typealias NetworkResponse<T> = (_ response: HTTPURLResponse, _ data: Data) throws -> T
    
    static var extractTokenWithStatusCode: NetworkResponse<CodestackResponseToken> {
        { response, data in
            if  (200..<300) ~= response.statusCode {
                do{
                    return try self.extractToken(data)
                }catch{
                    throw error
                }
            }else {
                throw APIError.httpResponseError(code: response.statusCode)
            }
        }
    }
    
    //TODO: 서버에서 오는 값은 accessToken만 재발급을 해야함
    static var extractToken: ExtractClosure<CodestackResponseToken> {
        { data in
            do {
                let token = try JSONDecoder().decode(CodestackResponseToken.self, from: data)
                return token
            } catch{
                throw APIError.decodingError
            }
        }
    }
    
    static var extractAccessToken: ExtractClosure<ReissueAccessToken> {
        { data in
            do {
                let token = try JSONDecoder().decode(ReissueAccessToken.self, from: data)
                return token
            } catch{
                throw APIError.decodingError
            }
        }
    }
}



extension API {
    
    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: getBaseURL(path: self)) else { throw APIError.badURLError }
        let header: [String : String] = commonHeader
        var body: [String : String] = [:]
        var method: String = "POST"
        
        switch self {
        case .reissue(let token):
            body = ["refreshToken" : token]
            
        case .regitster(let member):
            body = ["username": member.id,
                    "email" : member.email,
                    "password" : member.password,
                    "nickname" : member.nickName]
            
        case .password(let pwd,let newPwd):
            method = "PUT"
            body = ["password": pwd, "newPassword" : newPwd]
            
        case .profile(let image):
            return URLRequest.requestMultipart(url: url, image: image)
            
        case .health:
            method = "GET"
            body = [:]
            
        case .auth(let oAuthProvider):
            body = oAuthProvider.makeBody()
        }
        
        return URLRequest.request(url: url,
                                  headers: header,
                                  body: body,
                                  method: method)
    }
}




