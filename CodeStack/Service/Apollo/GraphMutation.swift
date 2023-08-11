//
//  GraphMutation.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/25.
//

import Foundation
import CodestackAPI

enum GraphMutation{
    static func problemSubmit(problemId: Double, languageId: Double, sourceCode: String) -> ProblemSubmitMutation {
        return ProblemSubmitMutation(problemId: problemId, languageId: languageId, sourceCode: sourceCode)
    }
}

