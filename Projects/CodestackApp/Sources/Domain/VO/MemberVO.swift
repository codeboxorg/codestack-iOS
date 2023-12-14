//
//  MemberVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import Data

public struct MemberNameVO: Codable {
    public let username: String
    
    public init(username: String) {
        self.username = username
    }
}

public struct MemberVO: Codable {
    public let id: ID
    public let email: String
    public let nickName: String
    public let imageURL: String
}


extension MemberDTO {
    func toDomain() -> MemberVO {
        MemberVO(id: self.id,
                 email: self.email,
                 nickName: self.nickName,
                 imageURL: self.imageURL ?? "codeStack")
    }
}
