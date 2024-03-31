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
    
    public var path: String = ""
    
    public var method: RequestMethod = .get
    
    public var header: [String : String]
    
    public var body: Data?
    
    public var queryParams: [String : String]?
    
    public init(_ token: String) {
        self.header = ["Content-Type": "application/json",
                       "Authorization" : "Bearer \(token)"]
        self.path = "\(projectPath)" + "/\(FireStore.stores.value)"
    }
    
    public init(_ token: String, _ uid: String) {
        self.init(token)
        self.path = "\(projectPath)" + "\(FireStore.posts(uid).value)"
    }
    
    public init(_ token: String, runQuery: Data?) {
        self.init(token)
        self.body = runQuery
        self.method = .post
        self.path = "\(self.projectPath)" + ":runQuery"
    }
}
