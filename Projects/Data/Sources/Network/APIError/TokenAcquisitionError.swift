//
//  Errorrs.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/05.
//

import Foundation

/// Errors recognized by the `TokenAcquisitionService`.
///
/// - unauthorized: It listens for and activates when it receives an `.unauthorized` error.
/// - refusedToken: It emits a `.refusedToken` error if the `getToken` request fails.
public enum TokenAcquisitionError: Error, Equatable {
    case undefinedURL
    case unauthorized
    case unowned
    case storeKeychainFailed
    case undefined
    case refusedToken(response: HTTPURLResponse, data: Data)
}
