//
//  MockWebRepository.swift
//  Domain
//
//  Created by 박형환 on 2/26/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift
@testable import Domain

public final class MockWebRepository: WebRepository {
    public func getMemberVO() -> MemberVO {
        .sample
    }
    
    public func updateEmail(_ email: String) {
        
    }
    
    public func updateMember(_ nickName: String) {
        
    }
    
    public func signUp(member: MemberVO) -> RxSwift.Maybe<Bool> {
        .never()
    }
    
    public func passwordChange(_ original: String, new: String) -> RxSwift.Maybe<Bool> {
        .never()
    }
    
    public func editProfile(_ image: Data) -> RxSwift.Maybe<ImageURL> {
        .never()
    }
    
    public func getMe() -> RxSwift.Maybe<MemberVO> {
        .never()
    }
    
    public func updateNickName(_ nickname: String) -> RxSwift.Maybe<MemberVO> {
        .never()
    }
    
    public func mapError(_ error: Error) -> Error? {
        nil
    }
    
    
}
