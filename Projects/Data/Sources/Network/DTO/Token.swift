//
//  ReissuedAccessToken.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/09.
//

import Foundation


public struct AsessToken: Codable {
    let accessToken: Token
    
    public init(accessToken: Token) {
        self.accessToken = accessToken
    }
}

public struct RefreshToken: Codable {
    let refresh: Token
    
    public init(refresh: Token) {
        self.refresh = refresh
    }
}
