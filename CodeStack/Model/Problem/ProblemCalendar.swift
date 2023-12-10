//
//  ProblemCalendar.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation

struct ProblemCalendar: Codable {
    let date: String
    let solved: Int
}

struct SubmissionCalendar: Codable {
    let dates: [String]
}

extension SubmissionCalendar {

    static func generateMockCalendar() -> Self {
        var date = Date()
        let dates = (0...200).map { num in
            let randomNumber = (0...200).randomElement()!
            let dateString = date.adding(day: -randomNumber).toString(format: .FULL)
            return dateString
        }
        return SubmissionCalendar(dates: dates)
    }
}

