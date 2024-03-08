//
//  TagDTO.swift
//  CSNetwork
//
//  Created by 박형환 on 3/8/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


public struct TagInfoDTO: Codable {
    public let tagList: [TagDTO]
    public let pageinfo: PageInfoDTO
    
    public init(tagList: [TagDTO], pageinfo: PageInfoDTO) {
        self.tagList = tagList
        self.pageinfo = pageinfo
    }
}

public struct TagDTO: Codable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct PageInfoDTO: Codable {
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
