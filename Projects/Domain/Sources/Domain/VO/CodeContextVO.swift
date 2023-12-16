//
//  CodeContextVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

public struct CodeContextVO {
    public var code: String
    public var problemID: String
    public var problemTitle: String
    
    public init(code: String, problemID: String, problemTitle: String) {
        self.code = code
        self.problemID = problemID
        self.problemTitle = problemTitle
    }
}
