//
//  FirestoreEndpoint.swift
//  Data
//
//  Created by 박형환 on 1/17/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public struct FireStoreEndPoint: EndPoint {
    
    public var host: String {
        firestoreBase
    }
    
    public var path: String {
        "\(projectPath)" + "/\(FireStore.stores.value)"
    }
    
    public var method: RequestMethod {
        .get
    }
    
    public var header: [String : String]
    
    public var body: Data?
    
    public var queryParams: [String : String]?
    
    public init(_ token: String) {
        self.header = ["Content-Type": "application/json",
                       "Authorization" : "Bearer \(token)"]
    }
}
