//
//  CodeTextView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/18.
//

import UIKit
import Highlightr
import RxSwift

class CodeUITextView: UITextView{
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addDoneButtonOnKeyboard()
    }
    required init?(coder: NSCoder) {
        fatalError("fattal error in codeUITextView this is not by using Storyboard")
    }
    
    deinit{
        print("CodeUITextView : deinit")
        
        
    }
    
    fileprivate func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: .zero)
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let up: UIBarButtonItem = UIBarButtonItem(title: "up", style: .plain, target: self, action: #selector(self.doneButtonAction))
        
        let items = [up,flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(_ sender: UIBarButtonItem){
        self.endEditing(true)
    }
    
}

