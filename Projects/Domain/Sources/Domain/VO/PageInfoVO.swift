//
//  PageInfoVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

public struct PageInfoVO: Codable {
    public let limit: Int
    public let offset: Int
    public let totalContent: Int
    public let totalPage: Int
    
    public init(limit: Int, offset: Int, totalContent: Int, totalPage: Int) {
        self.limit = limit
        self.offset = offset
        self.totalContent = totalContent
        self.totalPage = totalPage
    }
}
