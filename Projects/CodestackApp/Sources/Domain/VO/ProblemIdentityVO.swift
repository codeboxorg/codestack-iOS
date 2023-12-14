//
//  ProblemIdentityVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation


public struct ProblemIdentityVO: Codable, Equatable {
    public let id: String
    public let title: String
    
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}


public extension ProblemIdentityVO {
    
    func toProblemVO() -> ProblemVO {
        ProblemVO(id: self.id,
                  title: self.title,
                  context: "",
                  languages: [],
                  tags: [],
                  accepted: 0,
                  submission: 0,
                  maxCpuTime: "",
                  maxMemory: 0)
    }
}
