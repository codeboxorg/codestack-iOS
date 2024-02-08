//
//  UIViewController.swift
//  CodestackApp
//
//  Created by 박형환 on 1/15/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import CommonUI


enum Valid {
    case empty
    case corret
    case wrong
}

enum PATTERN {
    case id
    case password
    case email
    case nickname
    
    var pattern: String {
        switch self {
        case .id:
            return "^[a-z]+[a-z0-9]{4,19}$"
        case .password:
            return "^(?=.*[a-zA-Z])(?=.*[0-9]).{8,25}$"
        case .email:
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        case .nickname:
            return "^[ㄱ-ㅎ가-힣a-zA-Z0-9]{2,20}$"
        }
    }
}

extension UIViewController {
    func markColorWhenVaild(type: Valid, view: UIView) {
        switch type {
        case .empty:
            view.layer.borderColor = CColor.whiteGray.cgColor
        case .corret:
            view.layer.borderColor = CColor.green.cgColor
        case .wrong:
            view.layer.borderColor = CColor.red_up.cgColor
        }
    }
    
    func isValid(pattern: String, text: String, view: UITextField) -> Bool {
        if text.isEmpty {
            markColorWhenVaild(type: .empty, view: view)
            return false
        }
        let valid = self.isValidPattern(pattern: pattern, text: text)
        valid ? markColorWhenVaild(type: .corret, view: view) : markColorWhenVaild(type: .wrong, view: view)
        return valid
    }
    
    func isValidPattern(pattern: String, text: String) -> Bool {
        if let _ = text.range(of: pattern, options: .regularExpression) {
            return true
        } else {
            return false
        }
    }
}
