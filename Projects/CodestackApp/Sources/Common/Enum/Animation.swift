//
//  Animation.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import UIKit

enum Animation {
    typealias Element = (
        duration: TimeInterval,
        delay: TimeInterval,
        options: UIView.AnimationOptions,
        scale: CGAffineTransform,
        alpha: CGFloat
    )
    
   static var appearElement: Element {
        return Element(
            duration: 0.3,
            delay: 0,
            options: .curveLinear,
            scale: .init(scaleX: 1.0, y: 1.0),
            alpha: 1.0
        )
    }
    static var disappearElemet: Element {
         return Element(
            duration: 0.8,
            delay: 0.3,
             options: .curveLinear,
             scale: .init(scaleX: 1.0, y: 1.0),
             alpha: 0
         )
     }
    
}
