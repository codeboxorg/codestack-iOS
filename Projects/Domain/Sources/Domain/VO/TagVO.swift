//
//  TagVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation


public struct TagInfoVO: Codable {
    public let tagList: [TagVO]
    public let pageinfo: PageInfoVO
    
    public init(tagList: [TagVO], pageinfo: PageInfoVO) {
        self.tagList = tagList
        self.pageinfo = pageinfo
    }
}

public struct TagVO: Codable, Equatable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
