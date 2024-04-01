//
//  RegisterQuery.swift
//  Domain
//
//  Created by 박형환 on 12/16/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation


public struct RegisterQuery {
    public var id: String
    public var password: String
    public var email: String
    public var nickname: String
    public var isCorrectPassWord: String
    
    public init(id: String = "", password: String = "", email: String = "", nickname: String = "", isCorrectPassWord: String = "") {
        self.id = id
        self.password = password
        self.email = email
        self.nickname = nickname
        self.isCorrectPassWord = isCorrectPassWord
    }
}

public extension RegisterQuery {
    static var mock: Self {
        .init(id: "", password: "", email: "", nickname: "")
    }
}
