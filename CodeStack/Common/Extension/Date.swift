//
//  Date.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/24.
//

import Foundation


enum DATE{
    case DOT
    case FULL
    case YYYYMMDD
}

extension Date{
    
    func toString(format: DATE = .FULL) -> String{
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = getDateForMat(format)
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST") // "2018-03-21 18:07:27"
        return formatter.string(from: self)
    }
    
    private func getDateForMat(_ format: DATE) -> String{
        switch format {
        case .DOT:
            return "yyyy.MM.dd"
        case .FULL:
            return "yyyy-MM-dd HH:mm:ss"
        case .YYYYMMDD:
            return "yyyy-MM-dd"
        }
    }
}



extension Date {
    
    public static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    func dateComponent(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func dateComponent(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}



