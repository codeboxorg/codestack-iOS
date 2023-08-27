//
//  TimeInterval.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/24.
//

import Foundation


extension TimeInterval{

    func stringFromTimeInterval() -> String {

        let time = NSInteger(self)
        
        let year = (time / 3600) / 8064
        if year != 0 {return String(year) + TimeDiffereceType.year.rawValue }
        
        let month = (time / 3600) / 672
        if month != 0 {return String(month) + TimeDiffereceType.month.rawValue }
        
        let days = (time / 3600) / 24
        if days != 0 {return String(days) + TimeDiffereceType.day.rawValue }
        
        let hours = (time / 3600)
        if hours != 0 {return String(hours) + TimeDiffereceType.hour.rawValue }
        
        let minutes = (time / 60) % 60
        if minutes != 0 {return String(minutes) + TimeDiffereceType.minute.rawValue }
        
        let seconds = time % 60
        if seconds != 0 {return TimeDiffereceType.defalut.rawValue }
        
        return TimeDiffereceType.defalut.rawValue
    }
}
