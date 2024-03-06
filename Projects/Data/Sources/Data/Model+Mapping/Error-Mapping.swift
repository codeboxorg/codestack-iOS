//
//  Error-Mapping.swift
//  Data
//
//  Created by 박형환 on 1/18/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import CSNetwork
import Domain

public extension TokenAcquisitionError {
    func toDomain() -> TokenError {
        switch self {
        case .undefinedURL:
            return TokenError.undefinedURL
        case .unauthorized:
            return TokenError.unauthorized
        case .unowned:
            return TokenError.unowned
        case .storeKeychainFailed:
            return TokenError.storeKeychainFailed
        case .undefined:
            return TokenError.undefined
        case .refusedToken(let response, let data):
            return TokenError.refusedToken(response: response, data: data)
        }
    }
}
