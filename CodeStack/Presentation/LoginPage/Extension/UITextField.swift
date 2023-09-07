//
//  UITextField.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/02.
//

import UIKit


extension UITextField {

   func setPadding(left: CGFloat? = nil, right: CGFloat? = nil){
       if let left = left {
          let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.size.height))
          self.leftView = paddingView
          self.leftViewMode = .always
       }

       if let right = right {
           let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.size.height))
           self.rightView = paddingView
           self.rightViewMode = .always
       }
   }
    
    func textFieldSetting(place: String,
                          tag: Int,
                          vc: RegisterViewController,
                          secure: Bool = false ) -> UITextField {
        if secure {
            self.isSecureTextEntry = true
        }
        self.placeholder = place
        self.tag = tag
        self.delegate = vc
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 12
        self.layer.borderColor = Color.whiteGray.cgColor
        self.setPadding(left: 12)
        return self
    }
}
