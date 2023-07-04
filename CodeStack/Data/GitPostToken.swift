//
//  GitToken.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation


struct GitToken: Decodable{
    let accessToken: String
    let scope: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case scope
        case tokenType = "token_type"
    }
}
