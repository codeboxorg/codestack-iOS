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
        addDoneButtonOnKeyboard(#selector(doneButtonAction(_:)))
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
    
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var superRect = super.caretRect(for: position)
        guard let font = self.font else { return superRect }
        superRect.size.height = font.pointSize - font.descender
        return superRect
    }
    
    required init?(coder: NSCoder) {
        fatalError("fattal error in codeUITextView this is not by using Storyboard")
    }
    
    deinit{
        #if DEBUG
        print("CodeUITextView : deinit")
        #endif
    }
    
    fileprivate func addAttributes(){
        self.font = UIFont.boldSystemFont(ofSize: 14)
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

