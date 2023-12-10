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
    
    func toString(format: DATE = .FULL) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = getDateForMat(format)
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST") // "2018-03-21 18:07:27"
        return formatter.string(from: self)
    }
    
    private func getDateForMat(_ format: DATE) -> String {
        switch format {
        case .DOT:
            return "yyyy.MM.dd"
        case .FULL:
            return "yyyy-MM-dd HH:mm:ss"
        case .YYYYMMDD:
            return "yyyy-MM-dd"
        }
    }
    
    static func getDateFromCurrentMonth(count: Int = 5) -> [String] {
        let currentMonth = Calendar.current.dateComponents([.month], from: Date())
        let month: Int = currentMonth.month!
        var result: [String] = []
        result.append("\(month)월")
        var diffMonth: Int = month
        for _ in 1...4 {
            diffMonth -= 1
            if diffMonth <= 0 {
                diffMonth = 12
            }
            result.append("\(diffMonth)월")
        }
        return result.reversed()
    }
    
    /// '분' 더하는 메소드
    /// - Parameter day: 일자
    /// - Returns: 더해진 날짜
    func adding(day: Int) -> Date {
        let date = Calendar.current.date(byAdding: .day, value: day, to: self)!
        let formatter = Fommater.formatter
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = NSTimeZone(name: "ko_KR") as? TimeZone
        let str = formatter.string(from: date)
        return formatter.date(from: str)!
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



