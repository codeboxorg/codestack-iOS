//
//  API.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/08.
//

import Foundation
import CodestackAPI

public typealias Token = String
public typealias GitCode = String
public typealias ProblemID = String
public typealias SubmissionID = String
public typealias Pwd = String
public typealias NewPwd = String
public typealias ImageData = Data

public enum API {
    case graph(GRAPH)
    case rest(REST)
}

//MARK: CodeStackToken Decoding closure
extension API {
    
    public typealias ExtractClosure<T> = (Data) throws -> T
    public typealias NetworkResponse<T> = (_ response: HTTPURLResponse, _ data: Data) throws -> T
    
    public static var extractTokenWithStatusCode: NetworkResponse<CSTokenDTO> {
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
    
    // TODO: 서버에서 오는 값은 accessToken만 재발급을 해야함
    public static var extractToken: ExtractClosure<CSTokenDTO> {
        { data in
            do {
                let token = try JSONDecoder().decode(CSTokenDTO.self, from: data)
                return token
            } catch{
                throw APIError.decodingError
            }
        }
    }
    
    public static var extract: ExtractClosure<AsessToken> {
        { data in
            do {
                let token = try JSONDecoder().decode(AsessToken.self, from: data)
                return token
            } catch{
                throw APIError.decodingError
            }
        }
    }
    
    public static var extractAccessToken: ExtractClosure<RefreshToken> {
        { data in
            do {
                let token = try JSONDecoder().decode(RefreshToken.self, from: data)
                return token
            } catch{
                throw APIError.decodingError
            }
        }
    }
}


extension API {
    
    var base: String {
        guard let base = Bundle.main.infoDictionary?["codestack_endpoint"] as? String else { return "" }
        return base
    }
    
    var commonHeader: [String: String] {
        [ "Content-Type": "application/json"]
    }
    
    public func urlRequest() throws -> URLRequest {
        guard let url = URL(string: REST_ENDPOINT(path: self)) else { throw APIError.badURLError }
        var header: [String : String] = commonHeader
        var body: [String : Any] = [:]
        var method: String = RequestMethod.post.rv
        
        switch self {
        case .rest(let rest):
            switch rest {
            case .reissue(let token):
                body = ["refreshToken" : token.refresh]
                
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
                
            default:
                fatalError("not case value")
            }
        default:
            fatalError("did not founc REST TYPE")
        }
        
        return URLRequest.request(url: url, headers: header, body: body, method: method)
    }
}


