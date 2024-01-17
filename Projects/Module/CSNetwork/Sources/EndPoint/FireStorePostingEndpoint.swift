//
//  FireStorePostingEndpoint.swift
//  Data
//
//  Created by 박형환 on 1/17/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public struct FireStorePostingEndPoint: EndPoint {
    
    public var host: String {
        firestoreBase
    }
    
    public var path: String
    
    public var method: RequestMethod {
        .get
    }
    
    public var header: [String : String] = [ "Content-Type": "application/json"]
    
    public var body: Data?
    
    public var queryParams: [String : String]?
    
    public init(_ token: String, _ docID: String) {
        self.header = ["Content-Type": "application/json",
                       "Authorization" : "Bearer \(token)"]
        self.path = ""
        defer {
            self.path =
            "\(self.projectPath)"
            + "/\(FireStore.documents)"
            + "/\(docID)"
        }
    }
}
