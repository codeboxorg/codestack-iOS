//
//  LanguageVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation


public struct LanguageVO: Codable, Equatable {
    public let id: String
    public let name: String
    public let `extension`: String
    
    public init(id: String, name: String, extension: String) {
        self.id = id
        self.name = name
        self.extension = `extension`
    }
}

public extension LanguageVO {
    
    static var languageMap: [String: LanguageVO] {
        [
            "C": LanguageVO(id: "50", name: "C", extension: ".c"),
            "C++": LanguageVO(id: "54", name: "C++", extension: ".cpp"),
            "Node": LanguageVO(id: "93", name: "Node", extension: ".c"),
            "Python3": LanguageVO(id: "92", name: "Python3", extension: ".py"),
            "Swift": LanguageVO(id: "83", name: "Swift", extension: ".swift"),
            "Go": LanguageVO(id: "95", name: "Go", extension: ".go")
        ]
    }
    
    static var languageID: [Int: LanguageVO] {
        [
            50: LanguageVO(id: "50", name: "C", extension: ".c"),
            54: LanguageVO(id: "54", name: "C++", extension: ".cpp"),
            93: LanguageVO(id: "93", name: "Node", extension: ".c"),
            92: LanguageVO(id: "92", name: "Python3", extension: ".py"),
            83: LanguageVO(id: "83", name: "Swift", extension: ".swift"),
            95: LanguageVO(id: "95", name: "Go", extension: ".go")
        ]
    }
    
    static var `default`: Self {
        LanguageVO(id: "54", name: "C++", extension: ".cpp")
    }
    
    static var sample: [Self] {
        let lang =  ["C", "C++", "Node", "GO", "Python3", "Swift"]
        let `extension` = [".c",".cpp", ".js", ".go", ".py", ".swift"]
        
        let languages = zip(lang,`extension`).enumerated().map { (value) in
            let (offset, (name, ex)) = value
            return languageMap[name] ?? .default
        }
        return languages
    }
}
