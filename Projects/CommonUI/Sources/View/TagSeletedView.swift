//
//  TagSeletedView.swift
//  CodestackApp
//
//  Created by 박형환 on 3/6/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import SnapKit

public final class TagSeletedView: BaseView {
    
    private(set) var hstackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        return stack
    }()
    
    public lazy var tagAddButton: RotateButton = {
        let rotateButton = RotateButton(width: 20, height: 18)
        return rotateButton
    }()
    
    public lazy var tagDescriptionLabel: InsetTextField = {
        let field = InsetTextField()
        field.delegate = self
        return field
    }()
    
    public var hideButton = CommonHideButton()
    
    public convenience init(action: @escaping (Bool) -> Void) {
        self.init(frame: .zero)
        hideButton.action = action
    }
    
    public var tagConContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    public lazy var tagContainer =
    TagContainer(
        deleteHandler: { [weak self] string in
            self?.delete(tag: string)
        }
    )
    
    public var tags: Set<String>? {
        didSet {
            if let tags {
                self.tagContainer.setTagItem(tags.sorted())
                let height = self.tagContainer.getCurrentIntrinsicHeight()
                self.tagConContainer.snp.updateConstraints { make in
                    make.height.equalTo(height).priority(.low)
                }
            } else {
                self.tagContainer.removeLaguageTag()
            }
        }
    }
    
    public func insert(tag string: String) {
        var tag = tags
        tags = nil
        tag?.insert(string)
        tags = tag
    }
    
    public func delete(tag string: String) {
        var tag = tags
        tags = nil
        tag?.remove(string)
        tags = tag
    }
    
    public func remakeTagHeightWhenTags(isHide: Bool) {
        if isHide {
            hideButton.snp.remakeConstraints { make in
                make.width.height.equalTo(25)
                make.trailing.top.equalToSuperview().inset(12)
                // make.bottom.equalToSuperview().inset(12)
            }
        } else {
            hideButton.snp.remakeConstraints { make in
                make.width.height.equalTo(25)
                make.trailing.top.equalToSuperview().inset(12)
            }
        }
        tagSeletedViewAnimation(tag: isHide)
        tagContainer.isHidden = isHide
    }
    
    private func tagSeletedViewAnimation(tag hideFlag: Bool) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            self.layoutIfNeeded()
            self.tagContainer.alpha = hideFlag ? 0 : 1
        }, completion: { [weak self] flag in
            guard let self else { return }
            if flag {
                self.tagContainer.isHidden
                = hideFlag
            }
        })
    }
    
    public override func addAutoLayout() {
        self.addSubview(tagAddButton)
        self.addSubview(tagDescriptionLabel)
        self.addSubview(hideButton)
        self.addSubview(tagContainer)
        
        tagAddButton.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.leading.top.equalToSuperview().inset(12)
        }
        
        tagDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(tagAddButton.snp.trailing).offset(12)
            make.centerY.equalTo(tagAddButton.snp.centerY)
            make.trailing.equalTo(hideButton.snp.leading).offset(-8)
        }
        
        hideButton.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.trailing.top.equalToSuperview().inset(12).priority(.high)
        }
        
        tagContainer.snp.makeConstraints { make in
            make.top.equalTo(tagAddButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40).priority(.low)
            make.bottom.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            ["구현"].forEach { self.tags?.insert($0) }
            self.tags = []
        })
    }
    
    public override func applyAttributes() {
        tagDescriptionLabel.font = .systemFont(ofSize: 15)
        tagDescriptionLabel.placeholder = "태그를 추가해주세요!"
        tagDescriptionLabel.layer.borderWidth = 0
        tagDescriptionLabel.tintColor = dynamicLabelColor
        tagDescriptionLabel.textColor = dynamicLabelColor
        
        hideButton
            .addAction(
                UIAction(handler: { [weak self] v in
                    self?.hideButton.hideFlag.toggle()
                    if let isHide = self?.hideButton.hideFlag {
                        self?.remakeTagHeightWhenTags(isHide: isHide)
                    }
                }),
                for: .touchUpInside
            )
        
        tagAddButton.addAction(
            UIAction(handler: { [weak self] _ in
                _ =
                (self?.tagAddButton.rotateFlag ?? false)
                ?
                self?.become() : self?.resign()
            }),
            for: .touchUpInside
        )
        
        tagDescriptionLabel.addAction(
            UIAction(handler: { [weak self] _ in
                if (self?.tagAddButton.rotateFlag ?? false) == false {
                    self?.tagAddButton.sendActions(for: .touchUpInside)
                }
            }),
            for: .editingDidBegin
        )
    }
    
    private func become() {
        self.tagDescriptionLabel.becomeFirstResponder()
        self.tagContainer.mode = .addingDelete
    }
    
    private func resign() {
        self.tagDescriptionLabel.resignFirstResponder()
        self.tagContainer.mode = .default
        self.tagDescriptionLabel.text = ""
    }
}

extension TagSeletedView: UITextFieldDelegate {
    
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let maxLength = 18
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)

        return newString.count <= maxLength
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let tagString = self.tagDescriptionLabel.text,
           tagString.count >= 2
        {
            self.insert(tag: tagString)
            self.tagDescriptionLabel.text = ""
        } else {
            self.tagAddButton.sendActions(for: .touchUpInside)
        }
        return true
    }
}
