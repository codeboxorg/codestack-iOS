//
//  UITextField.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/24.
//

import UIKit


class InsetTextField: UITextField {
    let inset: CGFloat = 20

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.boldSystemFont(ofSize: 14)
        self.textColor = UIColor.systemGray
        self.layer.borderColor = UIColor.systemGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("insetTtextField fattalError!")
    }
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , inset , inset)
    }

    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , inset , inset)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, inset)
    }
}
