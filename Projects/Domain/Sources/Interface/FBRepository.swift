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
    func fireStorePost() -> Observable<FBDocuments<Store>>
    func fetchPost(_ documentID: String) -> Observable<Post>
    
    func fsProfileUpdate(_ member: MemberVO) -> Observable<String>
    func fsProfileImageUpdate(_ name: String, _ data: Data) -> Observable<String>
}
