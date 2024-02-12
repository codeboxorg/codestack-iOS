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
import FirebaseAuth

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
    
    public func update(email: String) -> Maybe<String> {
        Maybe<String>.create { maybe in
            let dispatchItem = DispatchWorkItem {
                // MARK: Send Email Using FB
                FAuth.auth().currentUser?.updateEmail(to: email) { error in
                    if let error { maybe(.error(error))}
                    else { maybe(.success(email))}
                }
            }
            dispatchItem.perform()
            return Disposables.create { dispatchItem.cancel() }
        }
    }
    
    public func update(nickname: String) -> Completable {
        let firebaseIDToken = KeychainItem.currentFBIdToken
        let uid = KeychainItem.currentFBLocalID
        let query = UserGetQuery(uid: uid, token: firebaseIDToken, method: .patch)
        let userQuery = UserQuery(nickname: nickname, preferLanguage: "", query: query)
        return rest.post(FireStoreUserPostEndPoint(patch: userQuery))
    }
    
    public func update(profileImage: Data) -> Observable<String> {
        let path = KeychainItem.currentFBLocalID
        let endPoint = StorageEndPoint(path, body: profileImage, token: KeychainItem.currentFBIdToken)
        return rest.request(endPoint) {
            Log.debug("test: \($0)")
            return ""
        }.asObservable()
    }
}
