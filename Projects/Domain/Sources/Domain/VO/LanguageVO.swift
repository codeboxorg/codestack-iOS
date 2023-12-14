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
    static var `default`: Self {
        LanguageVO(id: "1",
                   name: "C",
                   extension: ".c")
    }
    
    static var sample: [Self] {
        let lang =  ["C", "C++", "Node", "GO", "Python3"]
        let `extension` = [".c",".cpp", ".js", ".go", ".py"]
        
        let languages = zip(lang,`extension`).enumerated().map { (value) in
            let (offset, (name, ex)) = value
            return LanguageVO(id: "\(offset + 1)", name: name, extension: "\(ex)")
        }
        return languages
    }
}
