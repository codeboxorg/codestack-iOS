//
//  LanguageDTO.swift
//  CSNetwork
//
//  Created by 박형환 on 3/8/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


public struct LanguageDTO: Codable, Equatable {
    public let id: String
    public let name: String
    public let `extension`: String
    
    public init(id: String, name: String, extension: String) {
        self.id = id
        self.name = name
        self.extension = `extension`
    }
}
