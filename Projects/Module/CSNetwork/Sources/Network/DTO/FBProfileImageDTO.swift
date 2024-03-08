//
//  FBProfileImageDTO.swift
//  CSNetwork
//
//  Created by 박형환 on 2/25/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public struct FBUserProfileImageDTO: Codable {
    public var profileURL: String = ""
    
    private enum StoreKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case profileURL
    }
    
    public init(profileURL: String = "") {
        self.profileURL = profileURL
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StoreKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(StringValue(value: profileURL), forKey: .profileURL)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StoreKey.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        profileURL = try fieldContainer.decode(StringValue.self, forKey: .profileURL).value
    }
}
