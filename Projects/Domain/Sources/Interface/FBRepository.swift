//
//  FireRepository.swift
//  Domain
//
//  Created by 박형환 on 1/9/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift

public protocol FBRepository {
    
    
    /// HTML 글을 파이어 스토어에 올리는 메서드
    /// - Parameter markDown: markDown String
    /// - Returns: 완료 Completable
    func writePostContent(_ markDown: String) -> Observable<[String: Any]?>
    func writePostConDefaulttent(_ store: StoreVO ,_ markDown: String) -> Observable<State<Void>>
    
    func fetchPostLists(offset: Int, limit: Int) -> Observable<[StoreVO]>
    func fireStorePost() -> Observable<DocumentVO>
    func fireStorePostMe() -> Observable<DocumentVO>
    
    func fetchOtherUser(uid: String) -> Observable<FBUserNicknameVO>
    
    func fetchPost(_ documentID: String) -> Observable<PostVO>
    
    func fetchProblem() -> Observable<[ProblemVO]>
    func uploadProblem(_ problem: ProblemVO) -> Observable<State<Void>>
    
    func fetchMyProfileImage() -> Observable<Data>
    
    func update(email: String) -> Maybe<String>
    func update(nickname: String) -> Completable
    func update(profileImage: Data, nickname: String) -> Observable<String>
}
