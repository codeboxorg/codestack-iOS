//
//  FBTokenVO.swift
//  Domain
//
//  Created by 박형환 on 1/9/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

/// 파이어 베이스 사용하기위한 익명 인증 토큰
public struct FBTokenVO: Codable {
    public let kind: String
    public let idToken: String
    public let refreshToken: String
    public let expiresIn: String
    public let localId: String
    
    public init(kind: String, idToken: String, refreshToken: String, expiresIn: String = "", localId: String) {
        self.kind = kind
        self.idToken = idToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.localId = localId
    }
}
