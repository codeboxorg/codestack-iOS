//
//  Double.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/18.
//

import Foundation



extension Double{
    
    /// 비율 구하는 함수
    /// - Parameters:
    ///   - decimal: 정수 1
    ///   - second: 정수 2
    /// - Returns: 비율
    func toRate(decimal count: Int = 2, second: Double) -> Double{
        let value = ((second) / (self)) * 100.0
        return Double(String(format: "%.\(count)f", value))!
    }
}
