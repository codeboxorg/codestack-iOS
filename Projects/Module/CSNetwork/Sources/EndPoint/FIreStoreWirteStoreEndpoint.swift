//
//  FIreStoreWirteStoreEndpoint.swift
//  CSNetwork
//
//  Created by 박형환 on 3/7/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public struct PostingQuery {
    public let token: String
    public let store: Store
    
    public init(token: String, store: Store) {
        self.token = token
        self.store = store
    }
}

public struct FireStoreWirteStoreEndPoint: EndPoint {
    public var host: String {
        firestoreBase
    }
    
    public var path: String
    
    public var method: RequestMethod = .post
    
    public var header: [String : String] = [ "Content-Type": "application/json"]
    
    public var body: Data?
    
    public var queryParams: [String : String]?
    
    public init(_ token: String, _ store: Store, method: RequestMethod? = .post) {
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
//    public init(patch query: UserQuery) {
//        self.init(get: query.query)
//        let dto = FBUserDTO(nickname: query.nickname,
//                            preferLanguage: query.preferLanguage,
//                            profileURL: query.profileImagePath)
//        let jsondata = try? JSONEncoder().encode(dto)
//        self.body = jsondata
//    }
}
