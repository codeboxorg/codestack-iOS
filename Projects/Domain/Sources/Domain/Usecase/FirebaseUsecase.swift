//
//  CodestackUsecase.swift
//  Domain
//
//  Created by 박형환 on 1/9/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift

public final class FirebaseUsecase {
    
    private let fbRepository: FBRepository
    
    public init(fbRepository: FBRepository) {
        self.fbRepository = fbRepository
    }
    
    public func fetchPostInfoList() -> Observable<DocumentVO> {
        fbRepository.fireStorePost()
    }
    
    public func fetchMePostList() -> Observable<[StoreVO]> {
        fbRepository.fireStorePostMe()
            .map { $0.store }
    }
    
    public func fetchPostList(_ offset: Int = 0, _ limit: Int = 20) -> Observable<[StoreVO]> {
        fbRepository.fetchPostLists(offset: offset, limit: limit)
    }
    
    public func fetchOtherUserImagePath(uid: String) -> Observable<String> {
        fbRepository.fetchOtherUser(uid: uid).map(\.profileImagePath)
    }
    
    public func fetchPostByID(_ documentID: String) -> Observable<PostVO> {
        fbRepository.fetchPost(documentID)
    }
    
    public func writeContent(_ markdown: String) -> Completable {
        .empty()
        // fbRepository.writePostContent(markdown)
    }
    
    public func writeContent(_ store: StoreVO, _ markdown: String) -> Observable<State<Void>> {
        fbRepository.writePostConDefaulttent(store, markdown)
    }
}
