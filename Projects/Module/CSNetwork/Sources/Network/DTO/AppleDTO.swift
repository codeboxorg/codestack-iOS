//
//  AppleToken.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/28.
//

import Foundation



public struct AppleDTO {
    public let authorizationCode: String
    public let user: String?
    
    public init(authorizationCode: String, user: String?) {
        self.authorizationCode = authorizationCode
        self.user = user
    }
}
