//
//  StorageEndPoint.swift
//  Data
//
//  Created by 박형환 on 1/17/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public struct StorageEndPoint: EndPoint {
    
    public var host: String {
        fireStorageBase
    }
    
    public var path: String
    
    public var method: RequestMethod {
        .post
    }
    
    public var header: [String : String]
    
    public var body: Data?
    
    public var queryParams: [String : String]? {
        ["alt" : "media"]
    }
    
    public init(_ path: String, body: Data? = nil, token: String) {
        self.header = ["Content-Type": "image/png",
                       "Authorization" : "Bearer \(token)"]
        self.body = body
        self.path = ""
        defer {
            self.path
            = 
            "\(storagePath)"
            + "/\(path)"
            + "/profile.png"
        }
    }
}
