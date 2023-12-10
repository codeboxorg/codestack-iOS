//
//  CodestackAuthorization.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/04.
//

import Foundation
import RxSwift

protocol CodestackAuthorization: OAuthorization{
    func request(name id: ID,password: Pwd) -> Maybe<CodestackResponseToken>
}
