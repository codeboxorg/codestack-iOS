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
    
    private(set) var titleTextLabel = UILabel().then { label in
        label.text = "제목"
    }
    
    private(set) var titleTextField = InsetTextField().then { field in
        field.placeholder = "제목을 입력해주세요"
    }
    
    private(set) var descriptionLabel = UILabel().then { label in
        label.text = "소개"
    }
    
    private(set) var descriptionField = InsetTextField().then { field in
        field.placeholder = "글에 대한 설명을 입력해주세요"
    }
    
    private(set) var tagSelectedView = TagSeletedView()
    
    lazy var contentTextView: UIView = self.makeSwiftDownView()
    
    override func addAutoLayout() {
        self.addSubview(titleTextField)
        self.addSubview(contentTextView)
        self.addSubview(titleTextLabel)
        self.addSubview(descriptionField)
        self.addSubview(descriptionLabel)
        self.addSubview(tagSelectedView)
    
        titleTextLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        descriptionLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        titleTextLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleTextField.snp.centerY)
            make.leading.equalToSuperview().inset(16)
        }
    
        titleTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalTo(titleTextLabel.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(descriptionField.snp.centerY)
            make.leading.equalToSuperview().inset(16)
        }
        
        descriptionField.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(24)
            make.leading.equalTo(descriptionLabel.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        tagSelectedView.snp.makeConstraints { make in
            make.top.equalTo(descriptionField.snp.bottom).offset(24)
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
        titleTextField.backgroundColor = UIColor.systemGray6
        
        descriptionField.tintColor = dynamicLabelColor
        descriptionField.textColor = dynamicLabelColor
        descriptionField.backgroundColor = UIColor.systemGray6
        
        titleTextLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleTextLabel.textColor = dynamicLabelColor
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 15)
        descriptionLabel.textColor = dynamicLabelColor
        
        tagSelectedView.tagAddButton.tintColor = dynamicLabelColor
        
        contentTextView.backgroundColor = UIColor.systemGray6
        contentTextView.layer.cornerRadius = 12
        // contentTextView.attributedText = NSAttributedString.getPlaceHolderAttributeText()
        contentTextView.tintColor = dynamicLabelColor
    }
}


// MARK: KeyBoard Appear / Disappear / Tag Strech Animation
extension WritePostingView {
    
    private enum TextViewContraintType {
        case 태그_숨김
        case 태그_등장
        case 키보드_등장_텍스트필드_포커스(keyboard: CGFloat)
        case 키보드_등장_텍스트뷰_포커스(keyboard: CGFloat)
        case 키보드_사라짐_태그숨김_상태
        case 키보드_사라짐_태그등장_상태
        case 키보드_사라짐_모두숨김_상태
        
    }
    
    private enum AnimationType {
        case keyboardAppear(CGRect)
        case keyboardDissapear(hideType: CommonHideButton.HideType)
        case tagHide(Bool)
        case nameIntroduceHide(Bool)
    }
    
    func tagHideSeletedAnimation() {
        tagSelectedView.hideButton.hideFlag.toggle()
        tagSelectedView.hideButton.hideFlagV2.toggle()
        _ = tagSelectedView.hideButton.hideFlag
        let hideFlagV2 = tagSelectedView.hideButton.hideFlagV2
        
        if case let .tagHide(flag) = hideFlagV2 {
            textViewAnimationTrigger(.tagHide(flag))
        } else if case let .nameIntroduceHide(flag) = hideFlagV2 {
            textViewAnimationTrigger(.nameIntroduceHide(flag))
        }
    }
    
    func keyboardAppear(_ rect: CGRect) {
        textViewAnimationTrigger(.keyboardAppear(rect))
    }
    
    func keyboardDisappear() {
        textViewAnimationTrigger(.keyboardDissapear(hideType: self.tagSelectedView.hideButton.hideFlagV2))
    }
    
    private func textViewAnimationTrigger(_ animationType: AnimationType) {
        switch animationType {
        case .keyboardAppear(let rect):
            keyBoardAppearConstraint(keyboard: rect.height)
            
        case .keyboardDissapear(let hideType):
            keyboardDissapearContraint(hideType: hideType)
            hiddenAction(isTextViewFocused: false)
            
        case .tagHide(let hideFlag):
            tagSelectedView.remakeTagHeightWhenTags(isHide: hideFlag)
            tagSeletedViewAnimation(tag: hideFlag)
            updateTextViewContraint(for: hideFlag)
            tagSelectedView.tagContainer.isHidden = hideFlag
            
        case .nameIntroduceHide(let hideFlag):
            keyBoardAppearConstraint(keyboard: 0)
            hiddenAction(isTextViewFocused: hideFlag)
        }
    }
    
    private func hiddenAction(isTextViewFocused: Bool) {
        self.titleTextLabel.isHidden = isTextViewFocused
        self.titleTextField.isHidden = isTextViewFocused
        self.descriptionField.isHidden = isTextViewFocused
        self.descriptionLabel.isHidden = isTextViewFocused
        self.tagSelectedView.isHidden = isTextViewFocused
    }
    
    private func updateTextViewContraint(for tagHide: Bool) {
        if tagHide {
            updateContentTextViewConstraint(type: .태그_숨김)
        } else {
            updateContentTextViewConstraint(type: .태그_등장)
        }
    }
    
    private func tagSeletedViewAnimation(tag hideFlag: Bool) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            self.layoutIfNeeded()
            self.tagSelectedView.tagContainer.alpha = hideFlag ? 0 : 1
        }, completion: { [weak self] flag in
            guard let self else { return }
            if flag {
                self.tagSelectedView.tagContainer.isHidden
                = hideFlag
            }
        })
    }
    
    private func keyBoardAppearConstraint(keyboard height: CGFloat) {
        if self.titleTextField.isFirstResponder ||
           self.descriptionField.isFirstResponder {
            updateContentTextViewConstraint(type: .키보드_등장_텍스트필드_포커스(keyboard: height))
        } else {
            updateContentTextViewConstraint(type: .키보드_등장_텍스트뷰_포커스(keyboard: height))
        }
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            if !self.titleTextField.isFirstResponder &&
                !self.descriptionField.isFirstResponder {
                hiddenAction(isTextViewFocused: true)
            }
            self.layoutIfNeeded()
        })
    }
    
    private func keyboardDissapearContraint(hideType: CommonHideButton.HideType) {
        if case let .tagHide(flag) = hideType {
            if flag {
                updateContentTextViewConstraint(type: .키보드_사라짐_태그숨김_상태)
            } else {
                updateContentTextViewConstraint(type: .키보드_사라짐_태그등장_상태)
            }
        } else if case let .nameIntroduceHide(flag) = hideType {
            if flag {
                // TODO: 임시로 상태 변경 -> View 추가해서 appear처리 해야할듯
                tagSelectedView.hideButton.hideFlagV2.toggle()
                updateContentTextViewConstraint(type: .키보드_사라짐_태그등장_상태)
            } else {
                updateContentTextViewConstraint(type: .키보드_사라짐_태그숨김_상태)
            }
        }
    }
    
    private func updateContentTextViewConstraint(type: TextViewContraintType) {
        switch type {
        case .태그_숨김:
            contentTextView.snp.remakeConstraints { make in
                make.top.equalTo(tagSelectedView.tagAddButton.snp.bottom).offset(24)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
        case .태그_등장:
            contentTextView.snp.remakeConstraints { make in
                make.top.equalTo(tagSelectedView.snp.bottom).offset(24)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
        case .키보드_등장_텍스트필드_포커스(let height):
             contentTextView.snp.remakeConstraints { make in
                 make.top.equalTo(tagSelectedView.snp.bottom).offset(24)
                 make.leading.trailing.bottom.equalToSuperview()
                 make.bottom.equalToSuperview().inset(height)
             }
            
        case .키보드_등장_텍스트뷰_포커스(let height):
            contentTextView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(height)
            }
            
        case .키보드_사라짐_태그숨김_상태:
            contentTextView.snp.remakeConstraints { make in
                make.top.equalTo(tagSelectedView.tagAddButton.snp.bottom).offset(24)
                make.leading.trailing.bottom.equalToSuperview()
            }
            
        case .키보드_사라짐_태그등장_상태:
            contentTextView.snp.remakeConstraints { make in
                make.top.equalTo(tagSelectedView.snp.bottom).offset(24)
                make.leading.trailing.bottom.equalToSuperview()
            }
        case .키보드_사라짐_모두숨김_상태:
            contentTextView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
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
