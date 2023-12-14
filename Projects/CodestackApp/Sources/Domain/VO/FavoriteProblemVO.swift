//
//  FavoriteProblemVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

public struct FavoriteProblemVO {
    public let problemID: String
    public let problmeTitle: String
    public let createdAt: Date
    
    public init(problemID: String, problmeTitle: String, createdAt: Date) {
        self.problemID = problemID
        self.problmeTitle = problmeTitle
        self.createdAt = createdAt
    }
}
