//
//  Toast.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import UIKit

struct Toast{
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
