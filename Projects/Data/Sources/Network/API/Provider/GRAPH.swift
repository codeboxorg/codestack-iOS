//
//  GRAPH.swift
//  Data
//
//  Created by 박형환 on 12/14/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

public enum GRAPH {
    case PR_BY_ID(ID)                                              // 특정 ID의 문제
    case PR_LIST(offset: Int, sort: String, order: String)         // 문제 리스트
    /// dfasf
    case SER_PR_LIST(keyword: String, limit: Int, order: String, sort: String)     // 문제 검색 리스트
    case SUB_LIST(offset: Int, sort: String, order: String)        // 제출 리스트
    case SUB_BY_PR_ID(offset: Int, problemId: Double)              // 제출 By 문제 아이디
    case SUB_BY_ID(id: ID)                                         // 제출 By ID
    case SUB_LIST_ME(username: String)                             // 나의 제출 리스트
    
    case ME_SUB_HISTORY(limit: Int, offset: Int)    // 나의 제출 기록 (날짜와 아이디만)
    case ME                                         // 멤버 조회
    
    case SOLVE_PR_LIST(username: String)     // solve한 문제 리스트
    case LANG_LIST(offset: Int)              // 언어 리스트
    case TAG_LIST                            // Tag 리스트
    
    case UPDATE_NICKNAME(nickname: String)   // 닉네임 업데이트
    case SUBMIT_SUB(languageId: ID, problemId: ID,sourceCode: String)  // 코드 제출하기
}
