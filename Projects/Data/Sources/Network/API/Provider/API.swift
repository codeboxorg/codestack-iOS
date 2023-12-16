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
    
    public static func GRAPH_MUTATION(path: GRAPH) -> any GraphQLMutation {
        switch path {
        case .SUBMIT_SUB(let grsubmit):
            return SubmitSubmissionMutation(languageId: grsubmit.languageId,
                                            problemId: grsubmit.problemId,
                                            sourceCode: grsubmit.sourceCode)
            
        case .UPDATE_NICKNAME(let nickname):
            return UpdateNickNameMutation(nickname: nickname)
        default:
            fatalError("graph Mutation Type mismatch")
        }
    }
    
    public static func GRAPH_QUERY(path: GRAPH) -> any GraphQLQuery {
        switch path {
        case .PR_BY_ID(let id):
            return FetchProblemByIdQuery.init(id: id)
        case .PR_LIST(let grar):
            return FetchProblemsQuery.init(offset: .init(integerLiteral: grar.offset),
                                           sort: .init(stringLiteral: grar.sort),
                                           order: .init(stringLiteral: grar.order))
            
        case .SER_PR_LIST(let keyword, let grar):
            return FetchSearchproblemsQuery.init(keyword: keyword, limit: grar.limit, order: grar.order, sort: grar.sort)
        case .SUB_LIST(let grar):
            return FetchSubmissionsQuery.init(offset: .init(integerLiteral: grar.offset),
                                              sort: .init(stringLiteral: grar.sort),
                                              order: .init(stringLiteral: grar.order))
        case .SUB_BY_PR_ID(let offset, let problemID):
            return FetchSubmissionByProblemIdQuery.init(offset: offset, problemId: problemID)
        case .SUB_BY_ID(let id):
            return FetchSubmissionByIdQuery(id: id)
        case .SUB_LIST_ME(let userName):
            return FetchMeSubmissionsQuery(username: userName)
            
        case .ME_SUB_HISTORY(let limit, let offset):
            return FetchMeSubmissionHistoryQuery.init(limit: .init(integerLiteral: limit), offset: .init(integerLiteral: offset))
        case .ME:
            return FetchMeQuery.init()
            
        case .SOLVE_PR_LIST(let name):
            return FetchSolvedProblemQuery.init(username: name)
        case .LANG_LIST:
            return FetchAllLanguageQuery.init()
        case .TAG_LIST:
            return FetchAllTagQuery.init(offset: 0)
            
        default:
            fatalError("mis match Type")
        }
    }
    
    public func REST_ENDPOINT(path: API) -> String {
        switch path {
        case .rest(let restAPI):
            switch restAPI {
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
        default:
            fatalError("not found")
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
    
    //TODO: 서버에서 오는 값은 accessToken만 재발급을 해야함
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
    
//    public static var extractToken: ExtractClosure<CSTokenDTO> { data in
//        do {
//            let token = try JSONDecoder().decode(CSTokenDTO.self, from: data)
//            return token
//        } catch {
//            throw APIError.decodingError
//        }
//    }
    
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
    
    public func urlRequest() throws -> URLRequest {
        guard let url = URL(string: REST_ENDPOINT(path: self)) else { throw APIError.badURLError }
        let header: [String : String] = commonHeader
        var body: [String : String] = [:]
        var method: String = "POST"
        
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
            }
        default:
            fatalError("did not founc REST TYPE")
        }
        
        return URLRequest.request(url: url, headers: header, body: body, method: method)
    }
}




