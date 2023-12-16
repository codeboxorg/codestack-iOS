//
//  MemberDTO.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/08.
//

import Foundation
import Domain

//MARK: REST API , 회원가입 모델로 사용
public struct MemberDTO: Codable {
    public let id: String
    public let password: Pwd
    public let email: String
    public let nickName: String
    public var imageURL: String?
    
    public init(id: String, password: Pwd, email: String, nickName: String, imageURL: String? = nil) {
        self.id = id
        self.password = password
        self.email = email
        self.nickName = nickName
        self.imageURL = imageURL
    }
}

extension MemberDTO {
    public func toDomain() -> MemberVO {
        MemberVO(email: self.email,
                 nickName: self.nickName,
                 username: "",
                 solvedProblems: [],
                 profileImage: self.imageURL ?? "codeStack")
    }
}
