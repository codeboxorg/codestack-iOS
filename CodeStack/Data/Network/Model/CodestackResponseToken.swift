//
//  CodestackLoginRespone.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/03.
//

import Foundation


struct CodestackResponseToken: Codable{
    let refreshToken: String
    let accessToken: String
    let expiresIn: TimeInterval
    let tokenType: String
    
    init(refreshToken: String, accessToken: String, expiresIn: TimeInterval, tokenType: String) {
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
    }
}


struct TokenInfo {
    let expiresIn: TimeInterval?
    let tokenType: String?
}
