//
//  MemberVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

public struct MemberNameVO: Codable, Equatable {
    public let username: String
    
    public init(username: String) {
        self.username = username
    }
}

public struct MemberVO: Codable {
    public let email: String
    public let nickName: String
    public let username: String
    public let solvedProblems: [ProblemIdentityVO]
    public let profileImage: String
    
    public init(email: String, nickName: String, username: String, solvedProblems: [ProblemIdentityVO], profileImage: String) {
        self.email = email
        self.nickName = nickName
        self.username = username
        self.solvedProblems = solvedProblems
        self.profileImage = profileImage
    }
}

public extension MemberVO {
    static var sample: Self {
        .init(email: "GUT", nickName: "환", username: "형환", solvedProblems: [], profileImage: "codeStack")
    }
}
