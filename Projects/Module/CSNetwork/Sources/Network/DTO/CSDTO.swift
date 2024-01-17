//
//  CodestackToken.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/04.
//

import Foundation


public struct CSDTO {
    public let id: String
    public let password: String
    
    public init(id: String, password: String) {
        self.id = id
        self.password = password
    }
}
