//
//  CodestackUsecase.swift
//  Domain
//
//  Created by 박형환 on 1/9/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift


protocol PostingUsecase {
    
    func fetchPostInfoList()
    
    func fetchMePostList()
    
    func fetchPostList(_ offset: Int, _ limit: Int)
    
    func fetchOtherUserImagePath(uid: String)
    
    func fetchPostByID(_ documentID: String)
    
    func writeContent(_ markdown: String)
    
    func writeContent(_ store: StoreVO, _ markdown: String)
}

extension PostingUsecase {
    func fetchPostList(_ offset: Int = 0, _ limit: Int = 20) { }
}

public final class DefaultPostingUsecase {
    
}

public enum PostingError: Error {
    case unowned
    case postingPublishFail
    case tranSactionBeginFail
    public var description: String {
        switch self {
        case .tranSactionBeginFail:
            return "트랜잭션 생성에 실패하였습니다."
        case .postingPublishFail:
            return "Posting 발행에 실패하였습니다."
        case .unowned:
            return "알수 없는 에러가 발생했습니다. 관리자에게 문의해주세요"
        }
    }
}

public final class FirebaseUsecase {
    
    private let fbRepository: FBRepository
    private let postingRepository: PostingRepository
    
    public init(fbRepository: FBRepository, postingRepostiroy: PostingRepository) {
        self.fbRepository = fbRepository
        self.postingRepository = postingRepostiroy
    }
    
    public func fetchPostInfoList() -> Observable<DocumentVO> {
        fbRepository.fireStorePost()
    }
    
    public func fetchMePostList() -> Observable<[StoreVO]> {
        fbRepository.fireStorePostMe()
            .map { $0.store }
    }
    
    public func fetchOtherUserImagePath(uid: String) -> Observable<String> {
        fbRepository
            .fetchOtherUser(uid: uid)
            .map(\.profileImagePath)
    }
    
    public func fetchPostList(_ offset: Int = 0, _ limit: Int = 20) -> Observable<[StoreVO]> {
        postingRepository
            .fetchPostLists(offset: offset, limit: limit)
    }
    
    public func fetchPostByID(_ documentID: String) -> Observable<PostVO> {
        postingRepository
            .fetchPost(documentID)
    }
    
    
    public func upLoadPosting(store: StoreVO, markdown: String) -> Observable<State<Void>> {
        postingRepository
            .upLoadPosting(store, markdown)
            .catchAndReturn(.failure(PostingError.unowned))
    }
    
    public func updatePosting(store: StoreVO, markdown: String) -> Observable<State<Void>> {
        postingRepository
            .updatePostContent(store, markdown)
            .catchAndReturn(.failure(PostingError.unowned))
    }
    
}
