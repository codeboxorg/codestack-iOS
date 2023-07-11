//
//  CodestackLoginRespone.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/03.
//

import Foundation


struct CodestackResponseToken: Codable{
    let refreshToken: String
    let accessToken: String
    let expiresIn: TimeInterval
    let tokenType: String
}
