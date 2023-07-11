//
//  Date-extension.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/07.
//

import Foundation


extension Date{
    func toString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: self) // 현재 시간의 Date를 format에 맞춰 string으로 반환
    }
}
