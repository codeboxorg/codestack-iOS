//
//  FBDocument.swift
//  Domain
//
//  Created by 박형환 on 1/14/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

//public struct FBDocuments<T: Codable>: Codable {
//    public let store: [T]
//    
//    public init(store: [T]) {
//        self.store = store
//    }
//    
//    private enum CodingKeys: String, CodingKey {
//        case store = "documents"
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(store, forKey: .store)
//    }
//}
//
//struct ArrayValue: Codable {
//    let arrayValue: [String: [StringValue]]
//    
//    private enum ArrayKeys: String, CodingKey {
//        case arrayValue
//    }
//    public init(arrayValue: [String: [StringValue]]) {
//        self.arrayValue = arrayValue
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: ArrayKeys.self)
//        try container.encode(self.arrayValue, forKey: .arrayValue)
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: ArrayKeys.self)
//        self.arrayValue = try container.decode([String : [StringValue]].self, forKey: .arrayValue)
//    }
//    
//}
//struct StringValue: Codable {
//    let value: String
//    
//    private enum CodingKeys: String, CodingKey {
//        case value = "stringValue"
//    }
//    
//    public init(value: String) {
//        self.value = value
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.value, forKey: .value)
//    }
//}
