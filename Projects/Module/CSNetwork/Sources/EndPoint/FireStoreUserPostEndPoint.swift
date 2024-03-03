//
//  FireStoreUserEndPoint.swift
//  CSNetwork
//
//  Created by 박형환 on 1/26/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public struct UserGetQuery {
    public let uid: String
    public let token: String
    public let method: RequestMethod
    
    public init(uid: String, token: String, method: RequestMethod) {
        self.uid = uid
        self.token = token
        self.method = method
    }
}

public struct UserQuery {
    public let nickname: String
    public let preferLanguage: String
    public let profileImagePath: String
    public let query: UserGetQuery
    
    public init(nickname: String, preferLanguage: String,
                profileImagePath: String, query: UserGetQuery)
    {
        self.nickname = nickname
        self.preferLanguage = preferLanguage
        self.query = query
        self.profileImagePath = profileImagePath
    }
}



public struct FireStoreUserPostEndPoint: EndPoint {
    public var host: String {
        firestoreBase
    }
    
    public var path: String
    
    public var method: RequestMethod
    
    public var header: [String : String]
    
    public var body: Data?
    
    public var queryParams: [String : String]?
    
    public init(get query: UserGetQuery) {
        self.header = ["Content-Type": "application/json",
                       "Authorization" : "Bearer \(query.token)"]
        self.path = ""
        self.method = query.method
        
        defer {
            self.path =
            "\(projectPath)" +
            "/\(FireStore.users.value)" +
            "/\(query.uid)"
        }
    }
    
    public init(post query: UserQuery) {
        self.init(get: query.query)
        self.queryParams = ["documentId" : "\(query.query.uid)"]
        let dto = FBUserDTO(nickname: query.nickname,
                            preferLanguage: query.preferLanguage,
                            profileURL: query.profileImagePath)
        let jsondata = try? JSONEncoder().encode(dto)
        self.body = jsondata
        
        defer {
            self.path =
            "\(projectPath)" +
            "/\(FireStore.users.value)"
        }
    }
    
    public init(patch query: UserQuery) {
        self.init(get: query.query)
        let dto = FBUserDTO(nickname: query.nickname,
                            preferLanguage: query.preferLanguage,
                            profileURL: query.profileImagePath)
        let jsondata = try? JSONEncoder().encode(dto)
        self.body = jsondata
    }
}
