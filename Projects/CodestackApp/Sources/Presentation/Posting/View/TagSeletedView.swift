//
//  TagSeletedView.swift
//  CodestackApp
//
//  Created by 박형환 on 3/6/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import CommonUI
import SnapKit
import Then

final class TagSeletedView: BaseView {
    
    private(set) var hstackView = UIStackView().then { stack in
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
    }
    
    private(set) lazy var tagAddButton = UIButton().then { button in
        let image = UIImage(systemName: "plus")!
            .resize(targetSize: CGSize(width: 20, height: 20))
            .withTintColor(self.dynamicLabelColor)
        button.setImage(image, for: .normal)
    }
    
    private(set) var tagDescriptionLabel = UILabel()
    
    private(set) lazy var hideButton = CommonHideButton()
    
    private(set) var tagConContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private(set) var tagContainer = TagContainer()
    
    private(set) var tags: Set<String>? {
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
    
    func remakeTagHeightWhenTags(isHide: Bool) {
        if isHide 
        {
            hideButton.snp.remakeConstraints { make in
                make.width.height.equalTo(25)
                make.trailing.top.equalToSuperview().inset(12)
                make.bottom.equalToSuperview().inset(12)
            }
        }
        else
        {
            hideButton.snp.remakeConstraints { make in
                make.width.height.equalTo(25)
                make.trailing.top.equalToSuperview().inset(12)
            }
        }
    }
    
    override func addAutoLayout() {
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
            make.trailing.greaterThanOrEqualTo(hideButton.snp.leading)
        }
        
        hideButton.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.trailing.top.equalToSuperview().inset(12)
        }
        
        tagContainer.snp.makeConstraints { make in
            make.top.equalTo(tagAddButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100).priority(.low)
            make.bottom.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.tags = []
            ["구현", "알고리즘", "프리절빙"].forEach { self.tags?.insert($0) }
        })
    }
    
    override func applyAttributes() {
        tagDescriptionLabel.font = .systemFont(ofSize: 13)
        tagDescriptionLabel.textColor = .placeholderText
        tagDescriptionLabel.text = "태그를 추가해주세요!"
    }
    
}
