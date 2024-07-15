//
//  FireStoreWriteEndpoint.swift
//  Data
//
//  Created by 박형환 on 1/17/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation



// FireStoreWriteEndPoint 수정
public struct FireStoreWriteEndPoint: EndPoint {
    public var host: String {
        firestoreBase
    }
    
    public var path: String = ""
    
    public var method: RequestMethod = .post
    
    public var header: [String : String] = [ "Content-Type": "application/json"]
    
    public var body: Data?
    
    public var queryParams: [String : String]?
    
    public init(
        token: String,
        post: Post,
        documentID: String,
        method: RequestMethod? = nil
    ) {
        self.header = ["Content-Type": "application/json",
                       "Authorization" : "Bearer \(token)"]
        
        self.body = try? JSONEncoder().encode(post)
        
        if let method {
            self.method = method
        }
        
        // 지정된 DocumentID를 경로에 포함
        defer {
            self.path = "\(self.projectPath)/\(FireStore.documents)/\(documentID)"
        }
    }
}

//public struct FireStoreWirteEndPoint: EndPoint {
//    public var host: String {
//        firestoreBase
//    }
//    
//    public var path: String
//    
//    public var method: RequestMethod = .post
//    
//    public var header: [String : String] = [ "Content-Type": "application/json"]
//    
//    public var body: Data?
//    
//    public var queryParams: [String : String]?
//    
//    public init(token: String, post: Post, method: RequestMethod? = nil) {
//        self.header = ["Content-Type": "application/json",
//                       "Authorization" : "Bearer \(token)"]
//        self.path = ""
//        
//        self.body = try? JSONEncoder().encode(post)
//        
//        if let method {
//            self.method = method
//        }
//        defer {
//            self.path =
//            "\(self.projectPath)"
//            + "/\(FireStore.documents)"
//        }
//    }
//}
