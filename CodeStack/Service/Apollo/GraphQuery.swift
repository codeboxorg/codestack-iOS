//
//  GraphQuery.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/25.
//

import Foundation
import CodestackAPI

enum GraphQuery{
    static func getAllLanguage() -> GetAllLanguageQuery{
        return GetAllLanguageQuery()
    }
    
    static func getAllSubmission(offset: Double, sort: String, order: String) -> GetAllSubmissionQuery{
        return GetAllSubmissionQuery(offset: .some(offset), sort: .some(sort), order: .some(order))
    }
    
    static func getAllTag() -> GetAllTagQuery{
        return GetAllTagQuery()
    }
    
    static func getProblems(offset: Double,sort: String, order: String) -> GetProblemsQuery{
        return GetProblemsQuery(offset: .some(offset), sort: .some(sort), order: .some(order))
    }
    
    static func getSubmissionById(id: Double) -> GetSubmissionByIdQuery{
        return GetSubmissionByIdQuery(id: id)
    }
}



