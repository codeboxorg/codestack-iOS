//
//  LanguageVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation


public struct LanguageVO: Codable {
    public let id: String
    public let name: String
    public let `extension`: String
    
    public init(id: String, name: String, extension: String) {
        self.id = id
        self.name = name
        self.extension = `extension`
    }
}
