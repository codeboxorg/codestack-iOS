//
//  EditorContainer.swift
//  CodestackApp
//
//  Created by 박형환 on 4/23/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import CommonUI
import UIKit
import Highlightr

final class EditorContainerView: BaseView {
    
    weak var highlightr: Highlightr?
    weak var textDelegate: CodeEditorViewController?
    
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
    
    func setDelegate(_ delegate: CodeEditorViewController) {
        codeUITextView.layoutManager.delegate = delegate
        codeUITextView.delegate = delegate
        numbersView.settingTextView(self.codeUITextView, tracker: delegate)
    }
    
    override func applyAttributes() {
        let black = self.highlightr?.theme.themeBackgroundColor
        self.codeUITextView.backgroundColor = black
        self.codeUITextView.layer.borderColor = black?.cgColor
        self.codeUITextView.tintColor = dynamicLabelColor
        self.codeUITextView.inputView?.tintColor = dynamicLabelColor
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
