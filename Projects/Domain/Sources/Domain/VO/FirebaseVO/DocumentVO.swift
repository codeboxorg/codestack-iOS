//
//  DocumentVO.swift
//  Domain
//
//  Created by 박형환 on 1/26/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


public struct DocumentVO {
    public let store: [StoreVO]
    
    public init(store: [StoreVO]) {
        self.store = store
    }
}


public struct StoreVO: Equatable {
    public let id: String
    public let title: String
    public let name: String
    public let date: String
    public let description: String
    public let markdownID: String
    public let tags: [String]
    
    public init(title: String, name: String, date: String, description: String, markdown: String, tags: [String]) {
        self.id = UUID().uuidString
        self.title = title
        self.name = name
        self.date = date
        self.description = description
        self.markdownID = markdown
        self.tags = tags
    }
}

public struct PostVO {
    
    public let markdown: String
    
    public init(markdown: String) {
        self.markdown = markdown
    }
}
