//
//  CodestackLoginRespone.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/03.
//

import Foundation


struct CodestackToken: Codable{
    let refreshToken: String
    let accessToken: String
    let expiresIn: String
    let tokenType: String
}
