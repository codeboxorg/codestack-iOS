//
//  ProfileUsecase.swift
//  Domain
//
//  Created by 박형환 on 12/15/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import Data

public typealias ImageURL = String

public final class ProfileUsecase {

    private let webRepository: WebRepository
    
    public init(webRepository: WebRepository) {
        self.webRepository = webRepository
    }

    public func fetchME() -> Observable<MemberVO> {
        webRepository.getMe().asObservable()
    }
    
    public func editProfile(data: Data) -> Observable<String> {
        webRepository.editProfile(data).asObservable()
    }
}
