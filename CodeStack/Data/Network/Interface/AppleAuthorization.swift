//
//  AppleAuthorization.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/04.
//

import Foundation
import RxSwift

protocol AppleAuthorization: AnyObject,OAuthorization{
    func request(with token: AppleToken) -> Maybe<CodestackResponseToken>
    func oAuthComplte(token: AppleToken)
}
