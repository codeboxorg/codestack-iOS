//
//  Store.swift
//  Domain
//
//  Created by 박형환 on 1/14/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public struct Store: Codable, Equatable {
    public let id: String
    public let title: String
    public let name: String
    public let date: String
    public let description: String
    public let markdownID: String
    public let tags: [String]
    
    
    private enum StoreKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case title
        case name
        case date
        case description
        case markdownID = "markdown"
        case tags = "tag"
    }
    
    public init(title: String, name: String, date: String, description: String, markdown: String, tags: [String]) {
        self.id = UUID().uuidString
        self.title = title
        self.name = name
        self.date = date
        self.description = description
        self.markdownID = markdown
        self.tags = tags
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StoreKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(StringValue(value: title), forKey: .title)
        try fieldContainer.encode(StringValue(value: name), forKey: .name)
        try fieldContainer.encode(StringValue(value: markdownID), forKey: .markdownID)
        try fieldContainer.encode(StringValue(value: date), forKey: .date)
        try fieldContainer.encode(StringValue(value: description), forKey: .description)
        let strValues = tags.map { StringValue(value: $0) }
        try fieldContainer.encode(ArrayValue(arrayValue: ["values" : strValues]), forKey: .tags)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StoreKey.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        title = try fieldContainer.decode(StringValue.self, forKey: .title).value
        name = try fieldContainer.decode(StringValue.self, forKey: .name).value
        markdownID = try fieldContainer.decode(StringValue.self, forKey: .markdownID).value
        date = try fieldContainer.decode(StringValue.self, forKey: .date).value
        description = try fieldContainer.decode(StringValue.self, forKey: .description).value
        let value = try fieldContainer.decode(ArrayValue.self, forKey: .tags)
        let newValue = value.arrayValue["values"] ?? []
        let strList = newValue.map { $0.value }
        self.tags = strList
        id = UUID().uuidString
    }
}
