//
//  Problem-Submission + Calendar.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

public struct SubmissionCalendarVO: Codable {
    public let dates: [String]
    
    public init(dates: [String]) {
        self.dates = dates
    }
}

extension SubmissionCalendarVO {

    public static func generateMockCalendar() -> Self {
        var date = Date()
        let dates = (0...200).map { num in
            let randomNumber = (0...200).randomElement()!
            
            let dateString = date.adding(day: -randomNumber).toString(format: .FULL)
            return dateString
        }
        return SubmissionCalendarVO(dates: dates)
    }
}


