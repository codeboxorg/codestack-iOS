//
//  UIView-Ext.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/22.
//

import UIKit

struct Toast{
    static func toastMessage(_ message: String,
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
        
        UIApplication.shared.keyWindow?.addSubview(messageView)
        
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
extension UIView {
    func toastMessage(_ message: String) {
        
        let appearElement = Animation.appearElement
        
        let disappearElement = Animation.disappearElemet
    
        
        
        let messageView = ToastMessageView(x: 25,
                                           y: 44,
                                           offset: Position.screenHeihgt - 200,
                                           messgae: message,
                                           font: UIFont.systemFont(ofSize: 16),
                                           background: UIColor.juhwang)
        
        
        UIApplication.shared.keyWindow?.addSubview(messageView)
        
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


private enum Animation {
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
