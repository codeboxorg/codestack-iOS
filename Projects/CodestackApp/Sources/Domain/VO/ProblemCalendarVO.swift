//
//  ProblemCalendarVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

public struct ProblemCalendarVO: Codable {
    public let date: String
    public let solved: Int
    
    public init(date: String, solved: Int) {
        self.date = date
        self.solved = solved
    }
}
