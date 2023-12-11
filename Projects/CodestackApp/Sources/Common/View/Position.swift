//
//  Position.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/22.
//

import UIKit

struct Position {
    
    static let screenWidth = UIApplication.shared.keyWindow?.frame.width ?? 0
    static let screenHeihgt = UIApplication.shared.keyWindow?.frame.height ?? 0
    
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
