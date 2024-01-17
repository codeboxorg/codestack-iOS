//
//  API-GRAPH.swift
//  Data
//
//  Created by 박형환 on 1/9/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import CodestackAPI

extension API {
    public static func GRAPH_MUTATION(path: GRAPH) -> any GraphQLMutation {
        switch path {
        case .SUBMIT_SUB(let grsubmit):
            return SubmitSubmissionMutation(languageId: grsubmit.languageId,
                                            problemId: grsubmit.problemId,
                                            sourceCode: grsubmit.sourceCode)
            
        case .UPDATE_NICKNAME(let nickname):
            return UpdateNickNameMutation(nickname: nickname)
        default:
            fatalError("graph Mutation Type mismatch")
        }
    }
    
    public static func GRAPH_QUERY(path: GRAPH) -> any GraphQLQuery {
        switch path {
        case .PR_BY_ID(let id):
            return FetchProblemByIdQuery.init(id: id)
        case .PR_LIST(let grar):
            return FetchProblemsQuery.init(offset: .init(integerLiteral: grar.offset),
                                           sort: .init(stringLiteral: grar.sort),
                                           order: .init(stringLiteral: grar.order))
            
        case .SER_PR_LIST(let keyword, let grar):
            return FetchSearchproblemsQuery.init(keyword: keyword, limit: grar.limit, order: grar.order, sort: grar.sort)
        case .SUB_LIST(let grar):
            return FetchSubmissionsQuery.init(offset: .init(integerLiteral: grar.offset),
                                              sort: .init(stringLiteral: grar.sort),
                                              order: .init(stringLiteral: grar.order))
        case .SUB_BY_PR_ID(let offset, let problemID):
            return FetchSubmissionByProblemIdQuery.init(offset: offset, problemId: problemID)
        case .SUB_BY_ID(let id):
            return FetchSubmissionByIdQuery(id: id)
        case .SUB_LIST_ME(let userName):
            return FetchMeSubmissionsQuery(username: userName)
            
        case .ME_SUB_HISTORY(let limit, let offset):
            return FetchMeSubmissionHistoryQuery.init(limit: .init(integerLiteral: limit), offset: .init(integerLiteral: offset))
        case .ME:
            return FetchMeQuery.init()
            
        case .SOLVE_PR_LIST(let name):
            return FetchSolvedProblemQuery.init(username: name)
        case .LANG_LIST:
            return FetchAllLanguageQuery.init()
        case .TAG_LIST:
            return FetchAllTagQuery.init(offset: 0)
            
        default:
            fatalError("mis match Type")
        }
    }
}
