//
//  FireStoreProblemEndpoint.swift
//  CSNetwork
//
//  Created by 박형환 on 3/8/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation




public struct FireStoreProblemEndPoint: EndPoint {
    
    public var host: String {
        firestoreBase
    }
    
    public var path: String
    
    public var method: RequestMethod = .get
    
    public var header: [String : String] = [ "Content-Type": "application/json"]
    
    public var body: Data?
    
    public var queryParams: [String : String]?
    
    
    public init(_ token: String) {
        self.header = ["Content-Type": "application/json",
                       "Authorization" : "Bearer \(token)"]
        self.path = ""
        defer {
            self.path =
            "\(self.projectPath)"
            + "/\(FireStore.problems)"
        }
    }
    
    
    public init(_ token: String, problemID: String) {
        self.init(token)
        self.path = ""
        method = .post
        self.body = Self.problemQuery(id: problemID)
        defer {
            self.path = "\(self.projectPath)" + ":runQuery"
        }
    }
    
    
    public init(post problem: ProblemDTO, _ token: String) {
        self.init(token)
        self.method = .post
        self.body = try? JSONEncoder().encode(problem)
    }
}

extension FireStoreProblemEndPoint {
    
    static func problemQuery(id: String) -> Data? {
        """
        {
            "structuredQuery": {
                    "from": [{"collectionId": "problems"}],
                    "where": {
                    "fieldFilter": {
                        "field": { "fieldPath": "id" },
                        "op": "EQUAL",
                        "value": { "stringValue": "12" }
                    }
                }
            }
        }
        """.data(using: .utf8)
    }
}
