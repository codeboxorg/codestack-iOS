//
//  Color.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/25.
//

import UIKit



// CustomColor

typealias Color = CustomColor

enum CustomColor{
    
    case juhwang
    case juhwang_2
    case red
    case red_up
    case whiteGray
    case powder_blue
    case sky_blue
    case label
    case green
    case black
    
    var color: UIColor {
        switch self {
        case .juhwang:
            return UIColor(hexCode: "#ff7f00")
        case .juhwang_2:
            return UIColor(hexCode: "#FC4F08")
        case .red:
            return UIColor(hexCode: "#FAE9DE")
        case .whiteGray:
            return UIColor(hexCode: "F4EEEE")
        case .green:
            return UIColor(hexCode: "A2FF86")
        case .powder_blue:
            return UIColor(hexCode: "#B0E0E6")
        case .sky_blue:
            return UIColor(hexCode: "#87CEEB")
        case .red_up:
            return UIColor(hexCode: "FF6B6B")
        case .label:
            return .label
        case .black:
            return UIColor(hexCode: "19282F")
            
        }
    }
    var cgColor: CGColor{
        return self.color.cgColor
    }
}

extension UIColor {
    static func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}

extension UIColor{
    static let juhwang: UIColor = UIColor(hexCode: "#ff7f00")
    static let whiteGray: UIColor = UIColor(hexCode: "F4EEEE")
    static let red_c: UIColor = UIColor(hexCode: "#FAE9DE")
    static let juhwang_2: UIColor = UIColor(hexCode: "#FC4F08")
    static let powder_blue: UIColor = UIColor(hexCode: "#B0E0E6")
    static let sky_blue: UIColor = UIColor(hexCode: "#87CEEB")

}



extension UIColor {
    
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}
