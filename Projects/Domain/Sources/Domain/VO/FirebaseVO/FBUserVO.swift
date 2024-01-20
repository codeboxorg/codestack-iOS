//
//  FBUserVO.swift
//  Domain
//
//  Created by 박형환 on 1/19/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


public struct FBUserInfoVO {
    public let email: String
    public let nickname: String
    public let password: String
    public let fbTokenVO: FBTokenVO
    
    public init(email: String, nickname: String, password: String, fbTokenVO: FBTokenVO) {
        self.email = email
        self.nickname = nickname
        self.password = password
        self.fbTokenVO = fbTokenVO
    }
}
extension FBUserInfoVO {
    public func toVO() -> MemberVO {
        .init(email: self.email,
              nickName: self.nickname,
              username: "",
              solvedProblems: [],
              profileImage: "")
    }
}
