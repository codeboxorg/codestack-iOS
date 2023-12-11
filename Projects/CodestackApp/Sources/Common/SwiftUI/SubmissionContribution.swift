//
//  Submission.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//

import Foundation

struct SubmissionContribution {
    
    enum Depth: Int, CaseIterable {
        case zero, one, two, three, four
        func applyOpacity() -> Double {
            switch self {
            case .zero:
                return 0.1
            case .one:
                return 0.4
            case .two:
                return 0.6
            case .three:
                return 0.8
            case .four:
                return 1.0
            }
        }
    }
    
    let date: Date
    let count: Int
    let depth: Depth
    
    init(date: Date, submit count: Int, depth: Depth = .zero) {
        self.date = date
        self.count = count
        self.depth = depth
    }
    
    init(date: Date, submit count: Int){
        let depth: Depth
        switch count {
        case 0:
            depth = .zero
        case 1:
            depth = .one
        case 2:
            depth = .two
        case 3:
            depth = .three
        default:
            depth = .four
        }
        self.init(date: date, submit: count, depth: depth)
    }
}


extension SubmissionContribution.Depth {
    static func random() -> Self {
        Self.allCases.randomElement()!
    }
}
