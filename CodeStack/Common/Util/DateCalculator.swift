//
//  DateCalculator.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/24.
//

import Foundation

class Fommater {
    static let formatter: DateFormatter = DateFormatter()
}

struct DateCalculator{
    private var date: Date = Date()
    private var formatter = Fommater.formatter
    
    init(){
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST") // "2018-03-21 18:07:27"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    private func currentTime() -> String {
        let kr = formatter.string(from: date)
        return kr
    }
    
    /// 인자로 주어진 Date String을 계산하여 특정한 형식으로 변경
    /// - Parameter dateString: DateString
    /// - Returns: ex ) 방금전, 1분전, 1달전, 1년전
    func caluculateTime(_ dateString: String) -> String{
        let current = self.currentTime()
        
        let difference = formatter.date(from: current)! - formatter.date(from: dateString)!
        
        return difference.stringFromTimeInterval()
    }
}
