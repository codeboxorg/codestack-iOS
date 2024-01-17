//
//  FirebaseEndPoint.swift
//  Data
//
//  Created by 박형환 on 1/17/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public struct FirebaseAuthEndPoint: EndPoint {
    
    public var host: String {
        firebaseAuthBase
    }
    
    public var path: String {
        "/v1/accounts:signUp"
    }
    
    public var method: RequestMethod {
        .post
    }
    
    public var header: [String : String] = [ "Content-Type": "application/json"]
    
    public var body: Data?
    
    public var queryParams: [String : String]? {
        ["key" : firebaseAPIKey ]
    }
    
    public init() {
        self.body = try? JSONEncoder().encode([ "returnSecureToken": "true" ])
    }
}
