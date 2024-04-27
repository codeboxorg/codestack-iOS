//
//  UILabel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/30.
//

import UIKit

extension UILabel {
    func textWithAnimation(text: String, duration: CFTimeInterval) {
        fadeTransition(duration)
        self.text = text
    }
    
    //followed from @Chris and @winnie-ru
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
