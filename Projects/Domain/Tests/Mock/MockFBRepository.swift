//
//  MockFBRepository.swift
//  DomainTests
//
//  Created by 박형환 on 2/28/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
@testable import Domain
import RxSwift


public class MockFBRepository: FBRepository {
    
    public struct State {
        public var markdowns: [String: String]
        public var storePost: [String: DocumentVO]
        public var storeList: [StoreVO] = []
        public var profileImage: [String: Data]
        
        public var userInfo: FBUserInfoVO
        
        init(markdowns: [String : String] = [:],
             storePost: [String : DocumentVO] = [:],
             storeList: [StoreVO] = [],
             profileImage: [String : Data] = [:]) {
            
            self.userInfo = .init(email: "gudghks56@gmail.com",
                                  nickname: "stomHwan",
                                  password: "qwer1234",
                                  fbTokenVO: .init(kind: "bearer",
                                                   idToken: "sdafsfqfhjksjdfjk23123hsjaccessToken",
                                                   refreshToken: "fasjijkj12345Refresh",
                                                   localId: "TESTLOCALIDUUID@V4"))
            self.markdowns = markdowns
            self.storePost = storePost
            self.storeList = storeList
            self.profileImage = ["stomHwan" : Data()]
        }
    }
    
    public var state: State = .init()
    
    public func writePostContent(_ markDown: String) -> Completable {
        // TODO: This method will Change future to Below function
        .empty()
    }
    
    public func writePostContent(_ store: StoreVO ,_ markDown: String) -> Completable {
        let markDownID = store.markdownID
        self.state.storeList.append(store)
        
        return Completable.create { [unowned self] complete in
            self.state.markdowns["\(markDownID)"] = markDown
            complete(.completed)
            return Disposables.create {}
        }
    }
    
    public func fireStorePost() -> Observable<DocumentVO> {
        .just(DocumentVO(store: state.storeList))
    }
    
    public func fetchPost(_ documentID: String) -> Observable<PostVO> {
        if let markdown = state.markdowns[documentID] {
            return .just(PostVO(markdown: markdown))
        } else {
            print("markDown: \(state.markdowns)")
            return .just(.init(markdown: "abcd"))
        }
    }
    
    public func fetchMyProfileImage() -> Observable<Data> {
        let nickname = state.userInfo.nickname
        return .just(state.profileImage["\(nickname)"] ?? Data())
    }
    
    public func update(email: String) -> Maybe<String> {
        self.state.userInfo = FBUserInfoVO(email: email,
                                           nickname: self.state.userInfo.nickname,
                                           password: self.state.userInfo.password,
                                           fbTokenVO: self.state.userInfo.fbTokenVO)
        return .just("Success")
    }
    
    public func update(nickname: String) -> Completable {
        Completable.create { [unowned self] complete in
            self.state.userInfo = FBUserInfoVO(email: self.state.userInfo.email,
                                               nickname: nickname,
                                               password: self.state.userInfo.password,
                                               fbTokenVO: self.state.userInfo.fbTokenVO)
            complete(.completed)
            return Disposables.create {}
        }
    }
    
    public func update(profileImage: Data, nickname: String) -> Observable<String> {
        self.state.profileImage[nickname] = profileImage
        return .just(nickname)
    }
}
