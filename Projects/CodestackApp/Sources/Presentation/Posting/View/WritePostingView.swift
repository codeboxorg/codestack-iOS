//
//  WritePostingView.swift
//  CodestackApp
//
//  Created by 박형환 on 3/5/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import CommonUI
import UIKit
import SnapKit
import Then
import SwiftHangeul
import SwiftDown
import SwiftUI


final class WritePostingView: BaseView {
    
    static func create(with: SwiftDownEditor.ViewModel) -> WritePostingView {
        let view = WritePostingView(viewModel: with)
        return view
    }
    
    init(viewModel: SwiftDownEditor.ViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @ObservedObject private(set) var viewModel: SwiftDownEditor.ViewModel
    
    private var hanguelFactory = SwiftHangeul()
    private var inputFlag: Bool = false
    
    private(set) var titleTextField = InsetTextField().then { field in
        field.placeholder = "#제목"
        field.layer.borderWidth = 0
        field.font = UIFont.boldSystemFont(ofSize: 30)
    }
    
    private(set) lazy var tagSelectedView
    = TagSeletedView(
        action: { [weak self] (flag: Bool) in
            flag ? self?.tagHide() : self?.tagAppear()
            return
        }
    )
    
    lazy var contentTextView: UIView = self.makeSwiftDownView()
    
    override func addAutoLayout() {
        self.addSubview(titleTextField)
        self.addSubview(tagSelectedView)
        self.addSubview(contentTextView)
        self.backgroundColor = CColor.editorBlack.color
    
        titleTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalTo(self.snp.leading).offset(16)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        tagSelectedView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100).priority(.low)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(tagSelectedView.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func applyAttributes() {
        titleTextField.tintColor = dynamicLabelColor
        titleTextField.textColor = dynamicLabelColor
        titleTextField.backgroundColor = CColor.editorBlack.color
        
        tagSelectedView.tagAddButton.tintColor = dynamicLabelColor
        
        contentTextView.backgroundColor = UIColor.systemGray6
        contentTextView.layer.cornerRadius = 12
        // contentTextView.attributedText = NSAttributedString.getPlaceHolderAttributeText()
        contentTextView.tintColor = dynamicLabelColor
    }
    

    private(set) var keyboardHeight: CGFloat = 0
    
    private func tagHide() {
        contentTextView.snp.remakeConstraints { [unowned self] make in
            make.top.equalTo(tagSelectedView.tagAddButton.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(self.keyboardHeight)
        }
    }
    
    private func tagAppear() {
        contentTextView.snp.remakeConstraints { [unowned self] make in
            make.top.equalTo(tagSelectedView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().inset(self.keyboardHeight)
        }
    }
    
    func keyboardAppear(_ height: CGFloat) {
        self.keyboardHeight = height
        if tagSelectedView.tagDescriptionLabel.isFirstResponder == false &&
            titleTextField.isFirstResponder == false
        {
            contentTextView.snp.remakeConstraints { make in
                make.top.equalToSuperview().inset(5)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(self.keyboardHeight)
            }
            
            UIView.animate(
                withDuration: 0.2,
                animations: { [weak self] in
                    self?.tagSelectedView.isHidden = true
                    self?.titleTextField.isHidden = true
                    self?.layoutIfNeeded()
                }
            )
        }
    }
    
    func keyboardDissapear() {
        self.keyboardHeight = 0
        if titleTextField.isHidden == true {
            contentTextView.snp.remakeConstraints { [unowned self] make in
                let val = self.tagSelectedView.hideButton.hideFlag ?
                tagSelectedView.tagAddButton.snp.bottom : tagSelectedView.snp.bottom 
                
                make.top.equalTo(val).offset(24)
                make.leading.trailing.bottom.equalToSuperview()
            }
            
            UIView.animate(
                withDuration: 0.2,
                animations: { [weak self] in
                    self?.tagSelectedView.isHidden = false
                    self?.titleTextField.isHidden = false
                    self?.layoutIfNeeded()
                }
            )
        }
    }
}

extension WritePostingView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setPlaceHolderSeletedRange(textView)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        setPlaceHolderSeletedRange(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let paragraphRange = textView.getParagraphRange(range)
        
        if text.isBackSpaceKey() {
            // 삭제 && 전체 -> 전체 삭제니까 placeHolder text setting
            if range.length == hanguelFactory.length {
            
                while !hanguelFactory.getTotoal().isEmpty {
                    hanguelFactory.backKey()
                }
                
                return setPlaceHolderText(in: textView, range: range)
                
            } else {
                
                if hanguelFactory.length != range.location {
                    let beforeTextViewCount = hanguelFactory.length
                    hanguelFactory.insert(range: range, nil)
                    
                    // 전체 삭제가 아니면 그냥 true 리턴
                    let total = hanguelFactory.getTotoal()
                    textView.text = total
                    
                    textView.selectedRange
                    = beforeTextViewCount == hanguelFactory.length ?
                      NSRange(location: range.location, length: 0)
                    :
                      NSRange(location: range.location + text.count, length: 0)
                    
                } else {
                    hanguelFactory.input(nil)
                    // 전체 삭제가 아니면 그냥 true 리턴
                    let total = hanguelFactory.getTotoal()
                    textView.text = total
                }
                return false
            }
        } else {
            
            if hanguelFactory.length != range.location {
                let beforeTextViewCount = hanguelFactory.length
                hanguelFactory.insert(range: range, text)
                let total = hanguelFactory.getTotoal()
                textView.text = total
                
                // Text가 한글로 합쳐졌을때 Range를 변환 시켜야 합니다.
                textView.selectedRange
                = beforeTextViewCount == hanguelFactory.length ?
                  NSRange(location: range.location, length: 0)
                :
                  NSRange(location: range.location + text.count, length: 0)
                return false
            }
            
            if setDefaultText(in: textView, range: paragraphRange, text: text) {
                hanguelFactory.input(text)
                let total = hanguelFactory.getTotoal()
                textView.text = total
            } else {
                hanguelFactory.input(text)
            }
            
            return false
        }
    }
    
    private func setPlaceHolderSeletedRange(_ textView: UITextView){
        let paragraphRange = textView.getParagraphRange(textView.selectedRange)
        
        if paragraphRange.length == 0 { return }
        
        guard 
            let attributes = textView.textStorage.attribute(.foregroundColor,
                                                            at: paragraphRange.location,
                                                            effectiveRange: nil) as? UIColor else {
            return
        }
        
        if attributes == UIColor.placeholderText {
            textView.selectedRange = NSMakeRange(paragraphRange.location, 0)
        }
        return
    }
    
    private func setPlaceHolderText(in textView: UITextView,
                                    range paragraphRange: NSRange) -> Bool{
        
        if paragraphRange.location == 0 && paragraphRange.length == 0 { return false }
        
        textView.textStorage.beginEditing()
        textView.textStorage.replaceCharacters(in: paragraphRange,
                                               with: NSAttributedString.getPlaceHolderAttributeText())
        textView.textStorage.endEditing()
        
        textView.selectedRange = NSRange(location: 0, length: 0)
        return false
    }
    
    private func setDefaultText(in textView: UITextView,
                                range paragraphRange: NSRange,
                                text: String) -> Bool{
        guard  paragraphRange.length != 0,
              let color = textView.textStorage.attribute(.foregroundColor,
                                                         at: paragraphRange.location,
                                                         effectiveRange: nil) as? UIColor
        else { return true }
        
        let attributedString = NSAttributedString(string: text,
                                                  attributes: [
                                                    .foregroundColor : dynamicLabelColor,
                                                    .font : UIFont.boldSystemFont(ofSize: 16)])
        if color == UIColor.placeholderText {
            textView.textStorage.beginEditing()
            textView.textStorage.replaceCharacters(in: paragraphRange, with: attributedString)
            textView.textStorage.endEditing()
            
            textView.selectedRange = NSRange(location: text.count, length: 0)
            return false
        }
        
         return true
    }
}

extension NSAttributedString{
    static func getPlaceHolderString() -> String{
        return "내용을 입력해주세요"
    }
    
    static func getPlaceHolderAttributeText() -> NSAttributedString{
        return NSAttributedString(string: NSAttributedString.getPlaceHolderString(),
                                  attributes: [.foregroundColor : UIColor.placeholderText,
                                               .font : UIFont.boldSystemFont(ofSize: 16)])
    }
}
