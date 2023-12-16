//
//  SolvePageType.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import Foundation
import Domain

enum SolveResultType {
    case problem
    case result(SubmissionVO?)
    case resultList([SubmissionVO])
    
    var value: String {
        switch self {
        case .problem:
            return "problem"
        case .result:
            return "result"
        case .resultList:
            return "resultList"
        }
    }
    
    func isEqualStep(step: Self) -> Bool {
        self == step
    }
    
}
extension SolveResultType: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }
}
