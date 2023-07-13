//
//  Tag.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation

struct Tag: Codable{
    let id: String
    let name: String
}

struct _TagPagedResult: Codable{
    let content: [Tag]
    let pageInfo: _PageInfo
}
