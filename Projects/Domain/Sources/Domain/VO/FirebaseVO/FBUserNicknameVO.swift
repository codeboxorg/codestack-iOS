//
//  FBUserNickname.swift
//  Domain
//
//  Created by 박형환 on 1/29/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public struct FBUserNicknameVO: Codable {
    
    public let nickname: String
    public let preferLanguage: String
    public var profileImagePath: String
    
    public init(nickname: String, preferLanguage: String, profileImagePath: String) {
        self.nickname = nickname
        self.preferLanguage = preferLanguage
        self.profileImagePath = profileImagePath
    }
}
