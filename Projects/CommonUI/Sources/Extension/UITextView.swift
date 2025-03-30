//
//  UITextView.swift
//  CommonUI
//
//  Created by 박형환 on 3/5/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit



public extension UITextView {
    
    func addDoneButtonOnKeyboard(_ action: @escaping (UIAction) -> Void) {
        let doneToolbar: UIToolbar = UIToolbar(frame: .zero)
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", image: nil, primaryAction: UIAction(handler: action))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
    }
    
    func getParagraphRange(_ range: NSRange) -> NSRange {
        let allText: String = self.text
        let composeText: NSString = allText as NSString
        
        let paragraphRange = composeText.paragraphRange(for: range)
        return paragraphRange
    }
}
