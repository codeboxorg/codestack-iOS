//
//  UITextField.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/24.
//

import UIKit


public final class InsetTextField: UITextField {
    public var inset: CGFloat = 8
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        if let text = text,
           text.isEmpty {
            
        }
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        if let text = text,
           text.isEmpty {
            
        }
        return super.resignFirstResponder()
    }

    public override init(frame: CGRect) {
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
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , inset , inset)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , inset , inset)
    }

    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, inset)
    }
}
