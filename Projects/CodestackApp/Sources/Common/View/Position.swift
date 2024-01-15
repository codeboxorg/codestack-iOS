//
//  Position.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/22.
//

import UIKit

struct Position {
    
    enum Y {
        case top
        case mid
        case bottom
    }
    
    static func getYpos(_ y: Y) -> CGFloat {
        switch y {
        case .top:
            return 0
        case .mid:
            return Position.screenHeihgt / 2
        case .bottom:
            return Position.screenHeihgt
        }
    }
    
    static let screenWidth = UIApplication.shared.keyWindow?.frame.width ?? UIScreen.main.bounds.width
    static let screenHeihgt = UIApplication.shared.keyWindow?.frame.height ?? UIScreen.main.bounds.height
    
    static func getPosition(xPosition: CGFloat,
                            yPosition: CGFloat = 0,
                            yOffset: CGFloat,
                            defaultWidth: CGFloat = Position.screenWidth,
                            defaultHeight: CGFloat = 50)  -> CGRect {
        
        return CGRect(x: xPosition,
                      y: yPosition + yOffset ,
                      width: defaultWidth,
                      height: defaultHeight)
       }
    
}
