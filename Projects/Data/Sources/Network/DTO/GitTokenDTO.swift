//
//  GitToken.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation

public struct GitTokenDTO: Decodable {
    public let accessToken: String
    public let scope: String
    public let tokenType: String
    
    public init(accessToken: String, scope: String, tokenType: String) {
        self.accessToken = accessToken
        self.scope = scope
        self.tokenType = tokenType
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case scope
        case tokenType = "token_type"
    }
}




