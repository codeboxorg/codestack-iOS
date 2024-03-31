//
//  FIreStoreWirteStoreEndpoint.swift
//  CSNetwork
//
//  Created by 박형환 on 3/7/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


public struct FireStoreWirteStoreEndPoint: EndPoint {
    public var host: String {
        firestoreBase
    }
    
    public var path: String
    
    public var method: RequestMethod {
        .post
    }
    
    public var header: [String : String] = [ "Content-Type": "application/json"]
    
    public var body: Data?
    
    public var queryParams: [String : String]?
    
    public init(_ token: String, _ store: Store) {
        self.header = ["Content-Type": "application/json",
                       "Authorization" : "Bearer \(token)"]
        self.path = ""
        
        self.body = try? JSONEncoder().encode(store)
        
        defer {
            self.path =
            "\(self.projectPath)"
            + "/\(FireStore.stores)"
        }
    }
}
