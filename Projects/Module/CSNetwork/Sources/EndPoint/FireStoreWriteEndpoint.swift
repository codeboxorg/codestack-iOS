//
//  FireStoreWriteEndpoint.swift
//  Data
//
//  Created by 박형환 on 1/17/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public struct FireStoreWirteEndPoint: EndPoint {
    public var path: String {
        firestoreBase + "/\(FireStore.stores.value)"
    }
    
    public var method: RequestMethod {
        .post
    }
    
    public var header: [String : String] = [ "Content-Type": "application/json"]
    
    public var body: Data?
    
    public var queryParams: [String : String]?
    
    public init(_ token: String) {
        self.header = ["Content-Type": "application/json",
                       "Authorization" : "Bearer \(token)"]
    }
}
