//
//  String-HTML-extension.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/26.
//

import UIKit


extension String {
  func htmlToAttributedString(font: UIFont, color: UIColor, lineHeight: CGFloat) -> NSAttributedString? {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
        
    let _ = color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
    let rgb = "rgb(\(red * 255),\(green * 255),\(blue * 255))"
        
    let newLineHeight = lineHeight / font.pointSize
        
    let newHTML = String(format:"<span style=\"font-family: '-apple-system', '\(font.fontName)'; font-size: \(font.pointSize); color: \(rgb); line-height: \(newLineHeight);\">%@</span>", self)
        
    guard let data = newHTML.data(using: .utf8) else {
      return NSAttributedString()
    }
    
    do {
      return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
    } catch {
      return NSAttributedString()
    }
  }
    
}
