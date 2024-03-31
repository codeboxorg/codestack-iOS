//
//  FIrestore.swift
//  Data
//
//  Created by 박형환 on 1/17/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public enum FireStore {
    case stores
    case posts(String)
    case documents
    case users
    case problems
    
    public var value: String {
        switch self {
        case .problems:
            return "problems"
        case .posts(let str):
            return "/users/\(str)/posts"
        case .stores:
            return "stores"
        case .documents:
            return "documents"
        case .users:
            return "users"
        }
    }
}
