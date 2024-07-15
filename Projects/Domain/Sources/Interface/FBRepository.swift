//
//  FireRepository.swift
//  Domain
//
//  Created by 박형환 on 1/9/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift


public protocol Repository { }
extension Repository {
    public func convertToDictionary(from text: String) throws -> [String: Any] {
        guard let data = text.data(using: .utf8) else { return [:] }
        let anyResult: Any = try JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: Any] ?? [:]
    }
}

public protocol PostingRepository: Repository {
    
    /// Posting을 Fetch하는 메서드
    /// - Parameters:
    ///   - offset: Offset
    ///   - limit: Fetch 해올 Content Limit
    /// - Returns: 원격 서버에 저장된 Posting을 반환하는 Observalbe
    func fetchPostLists(offset: Int, limit: Int) -> Observable<[StoreVO]>
    
    
    /// Posting ID 로 MarkDown 컨텐츠를 가져오는 메서드
    /// - Parameter documentID: 특정 Posting의 Document ID
    /// - Returns: PostVO(markDown) 객체 Observable
    func fetchPost(_ documentID: String) -> Observable<PostVO>
    
    
    /// HTML 글을 파이어 스토어에 올리는 메서드
    /// - Parameters:
    ///   - store: 포스팅 관련 데이터 모델
    ///   - markDown: MarkDown 문자열
    /// - Returns: 원견 서버에 저장 성공 여부 Observalbe
    func upLoadPosting(_ store: StoreVO ,_ markDown: String) -> Observable<State<Void>>
    
    /// 파이어베이스 구조변경으로 인한 안쓰는 메서드
    // func fireStorePost() -> Observable<DocumentVO>
    // func fireStorePostMe() -> Observable<DocumentVO>
    
    /// HTML 글을 파이어 스토어에 올리는 메서드, UseCase에서 호출하면 안될듯?
    /// - Parameter markDown: markDown String
    /// - Returns: 완료 Completable
    func upLoadMarkDown(_ markDown: String) -> Observable<[String: Any]?>
    
    
    /// Update Posting Method - 포스트 업데이트 메서드
    /// - Parameters:
    ///   - store: 수정된 포스팅 데이터
    ///   - markDown: MarkDown
    /// - Returns: 수정 성공 여부
    func updatePostContent(_ store: StoreVO ,_ markDown: String) -> Observable<State<Void>>
}



public protocol FBRepository: Repository {
    func fireStorePost() -> Observable<DocumentVO>
    func fireStorePostMe() -> Observable<DocumentVO>
    
    func fetchOtherUser(uid: String) -> Observable<FBUserNicknameVO>
    
    func fetchProblem() -> Observable<[ProblemVO]>
    
    func uploadProblem(_ problem: ProblemVO) -> Observable<State<Void>>
    
    func fetchMyProfileImage() -> Observable<Data>
    
    func update(email: String) -> Maybe<String>
    func update(nickname: String) -> Completable
    func update(profileImage: Data, nickname: String) -> Observable<String>
}


