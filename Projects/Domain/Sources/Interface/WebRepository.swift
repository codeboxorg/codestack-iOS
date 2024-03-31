//
//  ApolloServiceType.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/08.
//

import Foundation
import RxSwift


public protocol WebRepository: AnyObject {
    // MARK: User
    func getMemberVO() -> MemberVO
    func updateEmail(_ email: String)
    func updateMember(_ nickName: String)
    
    // MARK: REST
    func signUp(member: MemberVO) -> Maybe<Bool>
    
    /// Password
    func passwordChange(_ original: String, new: String) -> Maybe<Bool>
    func editProfile(_ image: Data) -> Maybe<ImageURL>
    
    
    // MARK: 지금도 사용가능
    func getMe() -> Maybe<MemberVO>
    func updateNickName(_ nickname: String) -> Maybe<MemberVO>
    
    func mapError(_ error: Error) -> Error?
}


public extension WebRepository {
    
    private static var endpoint: String {
        return Bundle.main.infoDictionary!["graphql_endpoint"] as! String
    }
    
    static var baseURL: URL {
        return URL(string: endpoint)!
    }
    
}
