//
//  CodestackLoginRespone.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/03.
//

import Foundation


public struct CSTokenDTO: Codable {
    public let refreshToken: String
    public let accessToken: String
    public let expiresIn: TimeInterval
    public let tokenType: String
    
    public init(refreshToken: String, accessToken: String, expiresIn: TimeInterval, tokenType: String) {
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
    }
}

public struct AsessToken: Codable {
    public let accessToken: Token
    
    public init(accessToken: Token) {
        self.accessToken = accessToken
    }
}

public struct RefreshToken: Codable {
    public let refresh: Token
    
    public init(refresh: Token) {
        self.refresh = refresh
    }
}


public struct TokenInfo {
    
    public let expiresIn: TimeInterval?
    public let tokenType: String?
    
    public init(expiresIn: TimeInterval?, tokenType: String?) {
        self.expiresIn = expiresIn
        self.tokenType = tokenType
    }
}
