//
//  RequestMethod.swift
//  Network
//
//  Created by 박형환 on 1/17/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case patch = "PATCH"
    case put = "PUT"
    
    public var rv: String {
        self.rawValue
    }
}
