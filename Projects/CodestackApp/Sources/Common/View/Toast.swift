//
//  Toast.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import UIKit
import SwiftUI

struct Toast {
    static func toastMessage(_ value: ToastValue = .sample,
                             pos: Position.Y,
                             xOffset: CGFloat = 12,
                             yOffset: CGFloat = 140,
                             height: CGFloat = 50,
                             container: UIView? = nil) {
        
        let moveUp = Animation.moveUpElement
        let mmoveDown = Animation.moveDownElement
        let toastV2 = ToastMessageViewV2(value: value) { binding in
            binding.wrappedValue.toggle()
        }
        
        let messageView = UIHostingController(rootView: toastV2).view!
        messageView.backgroundColor = .clear
        
        let width = Position.screenWidth - (xOffset * 2)
        let height: CGFloat = height
        
        let yPos = Position.getYpos(pos) - yOffset
        
        let rect = Position.getPosition(xPosition: xOffset,
                                        yPosition: yPos,
                                        yOffset: 0,
                                        defaultWidth: width,
                                        defaultHeight: height)
        
        let afterPos: CGPoint = rect.origin
        var initPos: CGPoint
        if pos == .top {
            initPos = .init(x: afterPos.x, y: -30)
        } else {
            initPos = .init(x: afterPos.x, y: Position.screenHeihgt)
        }
        
        messageView.frame = CGRect(origin: initPos, size: rect.size)
        messageView.alpha = 0.3
        
        if let container {
            container.addSubview(messageView)
        } else {
            UIApplication.shared.keyWindow?.addSubview(messageView)
        }
        
        UIView.animate(
            withDuration: moveUp.duration,
            delay: moveUp.delay,
            options: moveUp.options,
            animations: {
                messageView.frame.origin = afterPos
                messageView.alpha = moveUp.alpha
            }
            ,completion: {_ in
                messageView.frame.origin = afterPos
                DispatchQueue.main.asyncAfter(deadline: .now() + mmoveDown.delay) {
                    UIView.animate(
                        withDuration: mmoveDown.duration,
                        delay: 0,
                        options: mmoveDown.options,
                        animations: {
                            messageView.frame.origin = initPos
                            messageView.alpha = mmoveDown.alpha
                        }
                        ,completion: {_ in
                            messageView.removeFromSuperview()
                        })
                }
            })
    }
    
    
    
    static func toastMessage(_ message: String,
                             container: UIView? = nil,
                             x position: CGFloat = 25 ,
                             offset: CGFloat = 120,
                             font: UIFont = UIFont.boldSystemFont(ofSize: 14),
                             background color: UIColor = UIColor.sky_blue,
                             boader b_color: CGColor = UIColor.clear.cgColor,
                             boader width: CGFloat = 1) {
        
        let appearElement = Animation.appearElement
        
        let disappearElement = Animation.disappearElemet
        
        let messageView = ToastMessageView(x: position,
                                           y: 44,
                                           offset: offset,
                                           messgae: message,
                                           font: font,
                                           background: color)
        messageView.layer.borderColor = b_color
        messageView.layer.borderWidth = width
        
        if let container {
            container.addSubview(messageView)
        } else {
            UIApplication.shared.keyWindow?.addSubview(messageView)
        }
        
        UIView.animate(
            withDuration: appearElement.duration,
            delay: appearElement.delay,
            options: appearElement.options,
            animations: {
                messageView.transform = appearElement.scale
                messageView.alpha = appearElement.alpha
            }
            ,completion: {_ in
                UIView.animate(
                    withDuration: disappearElement.duration,
                    delay: disappearElement.delay,
                    options: disappearElement.options,
                    animations: {
                        messageView.transform = disappearElement.scale
                        messageView.alpha = disappearElement.alpha
                    }
                    ,completion: {_ in
                        messageView.removeFromSuperview()
                    })
            })
    }
}
