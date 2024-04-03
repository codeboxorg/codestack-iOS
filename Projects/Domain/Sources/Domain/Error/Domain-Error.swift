//
//  Domain-Error.swift
//  Domain
//
//  Created by 박형환 on 4/24/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public enum SendError: Error {
    case isEqualSubmission
    case fetchFailProblem
    case unowned
    case unauthorized
    case none
    
    public func getDescription() -> String {
        switch self {
        case .isEqualSubmission:
            return "동일한 제출내역이 존재합니다."
        case .fetchFailProblem:
            return "문제의 정보를 불러오는데 실패하였습니다."
        case .unauthorized:
            return "로그인 정보가 존재하지 않습니다."
        case .unowned, .none:
            return "알수 없는 에러가 발생하였습니다"
        }
    }
}

public enum JZError: Error {
    case isProcessing
    case exceededUsage
    case unknown
}

public enum TokenError: Error, Equatable {
    case undefinedURL
    case unauthorized
    case unowned
    case storeKeychainFailed
    case undefined
    case refusedToken(response: HTTPURLResponse, data: Data)
    
    public func getDesciption() -> String {
        switch self {
        case .undefinedURL:
            return "존재하지 않는 URL 입니다."
        case .unauthorized:
            return "인증에 실패하였습니다."
        case .storeKeychainFailed:
            return "키체인 저장에 실패하였습니다."
        case .undefined, .unowned:
            return "알려지지 않는 에러입니다."
        case .refusedToken(let response, let data):
            return "다시 로그인하시고 시도해주세요"
        }
    }
}
