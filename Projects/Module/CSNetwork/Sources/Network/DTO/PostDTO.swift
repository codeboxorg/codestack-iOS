//
//  Post.swift
//  Domain
//
//  Created by 박형환 on 1/14/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


public struct Post: Codable {
    
    public let markdown: String
    
    private enum StoreKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case markdown 
    }
    
    public init(_ markdown: String) {
        self.markdown = markdown
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StoreKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(StringValue(value: markdown), forKey: .markdown)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StoreKey.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        markdown = try fieldContainer.decode(StringValue.self, forKey: .markdown).value
    }
}
