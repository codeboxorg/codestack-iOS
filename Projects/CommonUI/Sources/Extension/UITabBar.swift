//
//  UITabBar.swift
//  CommonUI
//
//  Created by 박형환 on 2/1/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit


public extension UITabBar {
    func hideWithAnimation(action: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            guard !self.isHidden else { return }
            UIView.transition(with: self, duration: 0.2, options: .curveEaseIn,
                              animations: { () -> Void in
                print("hide height: \(self.frame.size.height)")
                self.frame.origin.y += 100
            }, completion: { _ in
                self.isHidden = true
            })
        }
    }

    func showWithAnimation(action: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            guard self.isHidden else { return }
            UIView.transition(with: self, duration: 0.15, options: .curveEaseOut,
                              animations: { () -> Void in
                self.isHidden = false
                self.frame.origin.y -= 100
                print("show height: \(self.frame.size.height)")
            }, completion: nil)
        }
    }
}
