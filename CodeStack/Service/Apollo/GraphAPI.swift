//
//  API.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/23.
//

import Foundation

enum GraphAPI{
    private static var endpoint: String {
        return Bundle.main.infoDictionary!["graphql_endpoint"] as! String
    }
    
    static var baseURL: URL {
        return URL(string: endpoint)!
    }
}
