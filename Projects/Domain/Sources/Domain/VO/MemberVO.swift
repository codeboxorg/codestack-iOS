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

public struct MemberVO: Codable, Equatable {
    public var email: String
    public var nickName: String
    public let username: String
    public let solvedProblems: [ProblemIdentityVO]
    public var profileImage: String
    public var preferLanguage: LanguageVO
    
    public init(email: String, nickName: String, username: String, solvedProblems: [ProblemIdentityVO], profileImage: String, preferLanguage: LanguageVO = .default) {
        self.email = email
        self.nickName = nickName
        self.username = username
        self.solvedProblems = solvedProblems
        self.profileImage = profileImage
        self.preferLanguage = preferLanguage
    }
}

public extension MemberVO {
    static var sample: Self {
        .init(email: "GUT", nickName: "N/A", username: "N/A", solvedProblems: [], profileImage: "codeStack")
    }
    
    var toNameVO: MemberNameVO {
        MemberNameVO(username: username)
    }
}
