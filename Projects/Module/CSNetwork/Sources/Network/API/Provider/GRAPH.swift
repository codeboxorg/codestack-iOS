//
//  Query.swift
//  CodestackApp
//
//  Created by 박형환 on 12/16/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

/// Graph Argument
public struct GRAR {
    public let limit: Int
    public let offset: Int
    public let sort: String
    public let order: String
    
    public init(limit: Int = 20, offset: Int, sort: String = "id", order: String = "asc") {
        self.limit = limit
        self.offset = offset
        self.sort = sort
        self.order = order
    }
}

/// Graph Argument
public struct GRSubmit {
    public let languageId: String
    public let problemId: String
    public let sourceCode: String
    
    public init(languageId: String, problemId: String, sourceCode: String) {
        self.languageId = languageId
        self.problemId = problemId
        self.sourceCode = sourceCode
    }
}

public enum GRAPH {
    /// 특정 ID의 문제
    case PR_BY_ID(String)
    /// 문제 리스트
    case PR_LIST(arg: GRAR)

    /// 문제 검색 리스트
    case SER_PR_LIST(keyword: String, arg: GRAR)

    /// 제출 리스트
    case SUB_LIST(arg: GRAR)
    /// 제출 By 문제 아이디
    case SUB_BY_PR_ID(offset: Int, problemId: Double)
    /// 제출 By ID
    case SUB_BY_ID(id: String)
    /// 나의 제출 리스트/
    case SUB_LIST_ME(username: String)
    /// 나의 제출 기록 (날짜와 아이디만)
    case ME_SUB_HISTORY(limit: Int, offset: Int)
    /// 멤버 조회
    case ME

    /// solve한 문제 리스트
    case SOLVE_PR_LIST(username: String)
    /// 언어 리스트/
    case LANG_LIST(offset: Int)
    /// Tag 리스트
    case TAG_LIST
    /// 닉네임 업데이트/
    case UPDATE_NICKNAME(nickname: String)
    /// 코드 제출하기/
    case SUBMIT_SUB(submit: GRSubmit)
}
