//
//  SolvePageType.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import Foundation


enum SolveResultType {
    case problem
    case result(Submission?)
    case resultList([Submission])
    
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
