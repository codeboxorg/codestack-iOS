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
    
    static var moveUpElement: Element {
        Element(
            duration: 0.23,
            delay: 0,
            options: .curveEaseIn,
            scale: .init(scaleX: 1.0, y: 1.0),
            alpha: 1.0
        )
    }
    
    static var moveDownElement: Element {
        Element(
            duration: 0.3,
            delay: 1.5,
            options: .curveEaseOut,
            scale: .init(scaleX: 1.0, y: 1.0),
            alpha: 0
        )
    }
    
    static var appearElement: Element {
        Element(
            duration: 0.3,
            delay: 0,
            options: .curveLinear,
            scale: .init(scaleX: 1.0, y: 1.0),
            alpha: 1.0
        )
    }
    static var disappearElemet: Element {
        Element(
            duration: 0.8,
            delay: 0.3,
            options: .curveLinear,
            scale: .init(scaleX: 1.0, y: 1.0),
            alpha: 0
        )
    }
}
