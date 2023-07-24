//
//  Color.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/25.
//

import UIKit


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
