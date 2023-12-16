//
//  ProblemCalendar.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation
import Global

struct ProblemCalendar: Codable {
    let date: String
    let solved: Int
}

public struct SubmissionCalendar: Codable {
    let dates: [String]
}

extension SubmissionCalendar {

    public static func generateMockCalendar() -> Self {
        let date = Date()
        let dates = (0...200).map { num in
            let randomNumber = (0...200).randomElement()!
            
            let dateString = date.adding(day: -randomNumber).toString(format: .FULL)
            return dateString
        }
        return SubmissionCalendar(dates: dates)
    }
}


