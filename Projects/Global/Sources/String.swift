//
//  String-Ext.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/18.
//

import UIKit

public extension String {
    
    func toYYMMDD() -> Date? {
        Fommater.formatter.dateFormat = "yyyy-MM-dd"
        Fommater.formatter.timeZone = TimeZone(abbreviation: "KST")
        Fommater.formatter.locale = Locale(identifier: "ko_kr")
        guard let date: Date = Fommater.formatter.date(from: self) else { return nil }
        return date
    }
    
    func toDateUTC() -> Date? {
        Fommater.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        Fommater.formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        guard let date: Date = Fommater.formatter.date(from: self) else { return nil }
        return date
    }
    
    func toDateKST() -> Date? {
        Fommater.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        Fommater.formatter.timeZone = TimeZone(abbreviation: "KST")
        Fommater.formatter.locale = Locale(identifier: "ko_kr")
        guard let date: Date = Fommater.formatter.date(from: self) else { return nil }
        return date
    }
    
    /// 시간형식이 맞지 않은 String Date를 Date로 변환후 KR 형식으로 String으로 변환
    /// - Parameter format: DATE string 형식
    /// - Returns: String -> Date -> String
    func toDateStringUTC(format: DATE) -> String? {
        self.toDateUTC()?.toString(format: format)
    }
    
    func toDateStringKST(format: DATE) -> String? {
        self.toDateKST()?.toString(format: format)
    }
    
    func isKSTORUTC() -> Date {
        if let kst = self.toDateKST() { return kst }
        if let utc = self.toDateUTC() { return utc }
        return Date()
    }
}

public extension String {
    
    /// String Height
    /// - Parameters:
    ///   - width: String의 최대 width
    ///   - font: 폰트
    /// - Returns: 글자 상하 길이 height
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    /// String width
    /// - Parameters:
    ///   - height: String의 최대 height
    ///   - font: 폰트
    /// - Returns: 글자 좌우 길이 width
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    

    func boxContainer(color: UIColor) -> NSAttributedString{
        let attStr = NSAttributedString(string: self,
                                        attributes: [NSAttributedString.Key.backgroundColor : color,
                                                     NSAttributedString.Key.kern : CGFloat(1.4)])
        return attStr
    }
}
