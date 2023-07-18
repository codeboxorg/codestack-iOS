//
//  UIColor-Ext.swift
//  CodeStack
//
//  Created by 박형환 on 2023/05/05.
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


