//
//  UIView-Ext.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/22.
//

import UIKit


extension UIView{
    
    func debugLayer(){
        self.layer.borderColor = UIColor.systemPink.cgColor
        self.layer.borderWidth = 1
    }
    
    func debugBackground(back: UIColor = .systemPink){
        self.backgroundColor = back
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


