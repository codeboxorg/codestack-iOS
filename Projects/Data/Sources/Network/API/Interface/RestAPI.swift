//
//  RestAPI.swift
//  Data
//
//  Created by 박형환 on 12/14/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift

public protocol RestAPI {
    func request<T>(_ api: API, operation: @escaping Operation<T>) -> Maybe<T>
    
    func signUp(member: MemberDTO) -> Maybe<Bool>
    
    var tokenService: TokenAcquisitionService<RefreshToken> { get }
    
    func editProfile(_ image: Data) -> Maybe<ImageURL>
    
    func passwordChange(_ original: Pwd, new: Pwd) -> Maybe<Bool>
    
    func reissueToken(token: RefreshToken) -> Observable<(response: HTTPURLResponse, data: Data)>
    
    var initialToken: RefreshToken { get set }
}
