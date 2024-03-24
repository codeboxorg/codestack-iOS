//
//  CodeVO.swift
//  Domain
//
//  Created by 박형환 on 2/29/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


public struct CodestackVO: Equatable {
    public let id: String
    public var name: String
    public var sourceCode: String
    public var languageVO: LanguageVO
    public var updatedAt: String
    public let createdAt: String
    
    public init(id: String,name: String, sourceCode: String, languageVO: LanguageVO, updatedAt: String, createdAt: String) {
        self.id = id
        self.name = name
        self.sourceCode = sourceCode
        self.languageVO = languageVO
        self.updatedAt = updatedAt
        self.createdAt = createdAt
    }
}

extension CodestackVO {
    public var isMock: Bool {
        self.id == "TestMockModel1234"
    }
    
    public static var new: Self {
        self.init(id: UUID().uuidString,
                  name: "",
                  sourceCode: "",
                  languageVO: .init(id: "", name: "", extension: ""),
                  updatedAt: Date().toString(),
                  createdAt: Date().toString())
    }
    
    public static var mock: Self {
        self.init(id: "TestMockModel1234",
                  name: "",
                  sourceCode: "",
                  languageVO: .init(id: "", name: "", extension: ""),
                  updatedAt: Date().toString(),
                  createdAt: Date().toString())
    }
}
