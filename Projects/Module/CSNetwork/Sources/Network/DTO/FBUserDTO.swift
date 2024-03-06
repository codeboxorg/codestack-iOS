//
//  ReissuedAccessToken.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/09.
//

import Foundation


public struct FBUserDTO: Codable {
    public let nickname: String
    public let preferLanguage: String
    public var profileURL: String = ""
    
    private enum StoreKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case nickname
        case preferLanguage
        case profileURL
    }
    
    public init(nickname: String, preferLanguage: String, profileURL: String) {
        self.nickname = nickname
        self.preferLanguage = preferLanguage
        self.profileURL = profileURL
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StoreKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(StringValue(value: nickname), forKey: .nickname)
        try fieldContainer.encode(StringValue(value: profileURL), forKey: .profileURL)
        try fieldContainer.encode(StringValue(value: preferLanguage), forKey: .preferLanguage)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StoreKey.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        nickname = try fieldContainer.decode(StringValue.self, forKey: .nickname).value
        preferLanguage = try fieldContainer.decode(StringValue.self, forKey: .preferLanguage).value
        profileURL = try fieldContainer.decode(StringValue.self, forKey: .profileURL).value
    }
}
