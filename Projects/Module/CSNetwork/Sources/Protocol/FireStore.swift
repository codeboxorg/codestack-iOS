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
    case documents
    
    public var value: String {
        switch self {
        case .stores:
            return "stores"
        case .documents:
            return "documents"
        }
    }
}
