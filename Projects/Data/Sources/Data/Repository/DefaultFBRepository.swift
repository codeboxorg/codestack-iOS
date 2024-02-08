//
//  FBRepository.swift
//  Data
//
//  Created by 박형환 on 1/9/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import Domain
import Global
import CSNetwork

public final class DefaultFBRepository: FBRepository {
    
    private let rest: RestAPI
    
    public init(rest: RestAPI) {
        self.rest = rest
    }
    
    public func fireStorePost() -> Observable<DocumentVO> {
        let endpoint = FireStoreEndPoint(KeychainItem.currentFBIdToken)
        return rest.request(endpoint) { op in
            try JSONDecoder().decode(FBDocuments<Store>.self, from: op)
        }
        .map { $0.toDomain() }
        .asObservable()
    }
    
    public func fetchPost(_ documentID: String) -> Observable<PostVO> {
        let endpoint = FireStorePostingEndPoint(KeychainItem.currentFBIdToken, documentID)
        return rest.request(endpoint) { data in
            try JSONDecoder().decode(Post.self, from: data)
        }
        .map { $0.toDomain() }
        .asObservable()
    }
    
    public func fsProfileUpdate(_ member: MemberVO) -> Observable<String> {
        .empty()
    }
    
    public func fsProfileImageUpdate(_ name: String, _ data: Data) -> Observable<String> {
        let endPoint = StorageEndPoint(name, body: data, token: KeychainItem.currentFBIdToken)
        return rest.request(endPoint) {
            Log.debug("test: \($0)")
            return ""
        }.asObservable()
    }
}
