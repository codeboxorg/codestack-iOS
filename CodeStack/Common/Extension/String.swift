//
//  String-Ext.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/18.
//

import UIKit


extension String{
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        guard let date: Date = dateFormatter.date(from: self) else {return Date()}
        return date
    }
    
    /// 시간형식이 맞지 않은 String Date를 Date로 변환후 KR 형식으로 String으로 변환
    /// - Parameter format: DATE string 형식
    /// - Returns: String -> Date -> String
    func toDateString(format: DATE) -> String{
        self.toDate().toString(format: format)
    }
}

extension String {
    
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
    

    func boxContainer() -> NSAttributedString{
        let attStr = NSAttributedString(string: self,
                                        attributes: [NSAttributedString.Key.backgroundColor : UIColor.juhwang,
                                                     NSAttributedString.Key.kern : CGFloat(1.4)])
        return attStr
    }
}
