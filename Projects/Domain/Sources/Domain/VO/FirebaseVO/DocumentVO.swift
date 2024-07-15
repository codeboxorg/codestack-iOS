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
    public let userId: String
    public let title: String
    public var name: String
    public let date: String
    public var imageURL: String
    public let description: String
    public var markdownID: String
    public let tags: [String]
    
    public init(id: String = UUID().uuidString,
                userId: String,
                title: String,
                name: String,
                date: String,
                imageURL: String = "", 
                description: String,
                markdown: String,
                tags: [String]) {
        self.id = id
        self.title = title
        self.userId = userId
        self.name = name
        self.date = date
        self.imageURL = imageURL
        self.description = description
        self.markdownID = markdown
        self.tags = tags
    }
}

public extension StoreVO {
    static var `default`: Self {
        .init(id: UUID().uuidString,
              userId: "storm",
              title: "",
              name: "",
              date: "",
              description: "",
              markdown: "",
              tags: [])
    }
    static var mock: Self {
        .init(id: "TestUID1234",
              userId: "storm",
              title: "StoreTest",
              name: "TestStore",
              date: "2030-12-15 10:10:10",
              description: "Test Description Test Description Test Description Test Description",
              markdown: "markdownIDString",
              tags: ["구현", "알고리즘", "자료구조"])
    }
    
    var isMock: Bool {
        self.id == "TestUID1234"
    }
    
    var isNotMock: Bool {
        self.id != "TestUID1234"
    }
    
    static func getMocksForHome(_ count: Int = 3) -> [Self] {
        (0...count).map { _ in StoreVO.mock }
    }
    
    static func makeViewModel(_ title: String, _ description: String , _ tags: [String]) -> StoreVO {
        StoreVO(userId: "",
                title: title,
                name: "",
                date: Date().toString(format: .YYYYMMDD),
                description: description,
                markdown: "",
                tags: tags)
    }
    
    func makeViewModel(nickname: String, imageURL: String, tags: [String] = []) -> StoreVO {
        StoreVO(
            userId: "",
            title: self.title,
            name: nickname,
            date: self.date,
            imageURL: imageURL,
            description: self.description,
            markdown: self.markdownID,
            tags: tags == [] ? self.tags : tags
        )
    }
}

public struct PostVO {
    public let markdown: String
    public init(markdown: String) {
        self.markdown = markdown
    }
}
