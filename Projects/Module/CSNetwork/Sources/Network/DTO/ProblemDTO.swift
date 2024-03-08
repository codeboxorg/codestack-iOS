//
//  ProblemDTO.swift
//  CSNetwork
//
//  Created by 박형환 on 3/8/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


public struct QueryResult<T: Codable>: Codable {
    public let readTime: String?
    public let document: T?
    
    private enum FieldKeys: String, CodingKey {
        case readTime, document
    }
}

public struct ProblemInfoDTO: Codable {
    public let probleminfoList: [ProblemDTO]
    
    public init(probleminfoList: [ProblemDTO]) {
        self.probleminfoList = probleminfoList
    }
}

public struct ProblemDTO: Codable {
    public let id: String
    public let title: String
    public let contextID: String
    public let languages: [String]
    public var tags: [String]
    public let accepted: String
    public let submission: String
    public let maxCpuTime: String
    public let maxMemory: String
    
    private enum StoreKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case id
        case title
        case contextID
        case languages
        case tags
        case accepted
        case submission
        case maxCpuTime
        case maxMemory
    }
    
    public init(id: String,
                title: String,
                contextID: String,
                languages: [String],
                tags: [String],
                accepted: String,
                submission: String,
                maxCpuTime: String,
                maxMemory: String) {
        self.id = id
        self.title = title
        self.contextID = contextID
        self.languages = languages
        self.tags = tags
        self.accepted = accepted
        self.submission = submission
        self.maxCpuTime = maxCpuTime
        self.maxMemory = maxMemory
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StoreKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(StringValue(value: id), forKey: .id)
        try fieldContainer.encode(StringValue(value: title), forKey: .title)
        try fieldContainer.encode(StringValue(value: contextID), forKey: .contextID)
        
        let languagesValues = languages.map { StringValue(value: $0) }
        try fieldContainer.encode(ArrayValue(arrayValue: ["values" : languagesValues]), forKey: .languages)
        
        let tagsValues = tags.map { StringValue(value: $0) }
        try fieldContainer.encode(ArrayValue(arrayValue: ["values" : tagsValues]), forKey: .tags)
        
        try fieldContainer.encode(StringValue(value: accepted), forKey: .accepted)
        try fieldContainer.encode(StringValue(value: submission), forKey: .submission)
        try fieldContainer.encode(StringValue(value: maxCpuTime), forKey: .maxCpuTime)
        try fieldContainer.encode(StringValue(value: maxMemory), forKey: .maxMemory)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StoreKey.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        id = try fieldContainer.decode(StringValue.self, forKey: .id).value
        title = try fieldContainer.decode(StringValue.self, forKey: .title).value
        contextID = try fieldContainer.decode(StringValue.self, forKey: .contextID).value
        
        let languages = try fieldContainer.decode(ArrayValue.self, forKey: .languages)
        let newValue = languages.arrayValue["values"] ?? []
        let strList = newValue.map { $0.value }
        self.languages = strList
        
        accepted = try fieldContainer.decode(StringValue.self, forKey: .accepted).value
        submission = try fieldContainer.decode(StringValue.self, forKey: .submission).value
        maxCpuTime = try fieldContainer.decode(StringValue.self, forKey: .maxCpuTime).value
        maxMemory = try fieldContainer.decode(StringValue.self, forKey: .maxMemory).value
        
        let value = try fieldContainer.decode(ArrayValue.self, forKey: .tags)
        let arrayValues = value.arrayValue["values"] ?? []
        let tags = arrayValues.map { $0.value }
        self.tags = tags
    }
}
