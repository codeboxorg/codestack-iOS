//
//  EditorContainer.swift
//  CommonUIDemo
//
//  Created by hwan on 3/25/25.
//  Copyright © 2025 com.hwan. All rights reserved.
//

import UIKit
import CommonUI
import Highlightr

final class EditorContainerView: BaseView {
    
    weak var highlightr: Highlightr?
    weak var textDelegate: CodeViewController?
    
    private let numberTextViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    let numbersView: LineNumberRulerView = {
        let view = LineNumberRulerView(frame: .zero, textView: nil)
        return view
    }()
    
    lazy var codeUITextView: CodeUITextView = {
        let textStorage = CodeAttributedString()
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)
        
        highlightr = textStorage.highlightr
        highlightr?.setTheme(to: "Xcode")
        
        let textView = CodeUITextView(frame: .zero, textContainer: textContainer)
        
        return textView
    }()
    
    func setDelegate(_ delegate: CodeViewController) {
        numbersView.settingTextView(self.codeUITextView, tracker: delegate)
    }
    
    override func applyAttributes() {
        let black = self.highlightr?.theme.themeBackgroundColor
        numberTextViewContainer.backgroundColor = black   
    }
    
    override func addAutoLayout() {
        self.addSubview(codeUITextView)
        codeUITextView.addSubview(numbersView)
        
        codeUITextView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        //MARK: TextContainer Inset -> 넘버 뷰의 위치의 텍스트입력 방지 inset
        var inset = codeUITextView.textContainerInset
        inset.left = 35
        codeUITextView.textContainerInset = inset
        
        numbersView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.bottom.equalToSuperview()
            make.height.equalTo(codeUITextView.bounds.height)
            make.width.equalTo(inset.left).priority(.high)
        }
    }
}

