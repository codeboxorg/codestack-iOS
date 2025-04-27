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
    
    private lazy var undoableManager: UndoableManager = DefaultUndoableManager(
        editor: self.codeUITextView
    )
    
    lazy var editorController = EditorController(
        dependency: .init(
            textView: self.codeUITextView,
            lineNumberView: self.numbersView,
            widthUpdater: self,
            buttonCommandExecuteManager: DefaultButtonCommandExecuteManager(
                editor: self.codeUITextView,
                undoableManager: self.undoableManager
            ),
            undoableManager: self.undoableManager
        )
    )
    
    let numberTextViewContainer: UIView = {
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
        let textView = CodeUITextView(frame: .zero, textContainer: textContainer)
        return textView
    }()
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.bounces = false
        scroll.showsHorizontalScrollIndicator = true
        scroll.showsVerticalScrollIndicator = false
        scroll.isScrollEnabled = true
        scroll.isDirectionalLockEnabled = true
        return scroll
    }()
    
    override func applyAttributes() {
        numbersView.settingTextView(self.codeUITextView, tracker: self)
        codeUITextView.languageBinding(name: "Swift")
        codeUITextView.layoutManager.delegate = editorController
        codeUITextView.delegate = editorController
        
        highlightr = (codeUITextView.textStorage as! CodeAttributedString).highlightr
        highlightr?.setTheme(to: "vs2015")
        let color = self.highlightr?.theme.themeBackgroundColor
        numberTextViewContainer.backgroundColor = color
        numbersView.backgroundColor = color
        codeUITextView.backgroundColor = color
    }
    
    override func addAutoLayout() {
        self.addSubview(scrollView)
    
        codeUITextView.addSubview(numbersView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(codeUITextView)
        
        codeUITextView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalToSuperview() // or intrinsic height
        }
        
        //MARK: TextContainer Inset -> 넘버 뷰의 위치의 텍스트입력 방지 inset
        var inset = codeUITextView.textContainerInset
        inset.left = numbersView.number_100_Width
        codeUITextView.textContainerInset = inset
        
        numbersView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.bottom.equalToSuperview()
            make.height.equalTo(codeUITextView.bounds.height)
            make.width.equalTo(inset.left).priority(.high)
        }
    }
}

extension EditorContainerView: TextViewWidthUpdateProtocol {
    func updateTextViewWidth(_ width: CGFloat) {
        codeUITextView.snp.updateConstraints { make in
            make.width.equalTo(width + 40)
        }
    }
    
    func positioningScrollView() {
        guard let selectedTextRange = codeUITextView.selectedTextRange else { return }
        
        let caretRect = codeUITextView.caretRect(for: selectedTextRange.start)
        let caretRectInScrollView = codeUITextView.convert(caretRect, to: scrollView)
        
        var targetRect = caretRectInScrollView
        targetRect.origin.x -= 100
        targetRect.size.width += 100
        
        scrollView.scrollRectToVisible(targetRect, animated: true)
    }
}

extension EditorContainerView: TextViewSizeTracker {
    func updateNumberViewsHeight(_ height: CGFloat){
        numbersView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
}
