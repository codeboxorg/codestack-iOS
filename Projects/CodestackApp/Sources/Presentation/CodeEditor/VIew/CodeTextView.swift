//
//  CodeTextView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/18.
//

import UIKit
import Highlightr
import RxSwift
import Domain

class CodeUITextView: UITextView {
    
    override var contentSize: CGSize {
        didSet {
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addDoneButtonOnKeyboard()
        self.isScrollEnabled = true
        self.layer.borderWidth = 1
        self.spellCheckingType = .no
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.autocorrectionType = UITextAutocorrectionType.no
        self.autocapitalizationType = UITextAutocapitalizationType.none
        self.alwaysBounceVertical = true
        
        self.text = """
#include <stdio.h>
    
int main() {
        
    return 0;
}
    
    
"""
    }
    
    required init?(coder: NSCoder) {
        fatalError("fattal error in codeUITextView this is not by using Storyboard")
    }
    
    deinit{
        print("CodeUITextView : deinit")
    }
    
    fileprivate func addAttributes(){
        self.font = UIFont.boldSystemFont(ofSize: 14)
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
    
    private var isFirst: Bool = true
    
    func languageBinding(language: LanguageVO) {
        let storage = (self.textStorage as! CodeAttributedString)
        
        if language.name == "Node" || language.name == "Node.js" {
            storage.language = "typescript"
        } else {
            if language.name == "Python3" {
                storage.language = "python"
            } else {
                storage.language = "\(language.name)"
            }
        }
    }
    
    func textBinding(sourceCode: String) {
        self.text = sourceCode
    }
}

