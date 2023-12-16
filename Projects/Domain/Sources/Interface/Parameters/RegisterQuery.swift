//
//  RegisterQuery.swift
//  Domain
//
//  Created by 박형환 on 12/16/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation


public struct RegisterQuery {
    public let id: String
    public let password: String
    public let email: String
    public let nickname: String
    
    public init(id: String, password: String, email: String, nickname: String) {
        self.id = id
        self.password = password
        self.email = email
        self.nickname = nickname
    }
}
