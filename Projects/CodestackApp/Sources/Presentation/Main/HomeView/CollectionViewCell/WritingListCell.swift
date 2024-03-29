//
//  WritingListCell.swift
//  CodestackApp
//
//  Created by 박형환 on 1/13/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import Global
import CommonUI

final class WritingListCell: UICollectionViewCell {
    
    let colorline: UIView = {
        let view = UIView()
        return view
    }()
    
    let titleTagView: TagView = {
        let view = TagView(frame: .zero, corner: 8, background: .magenta, text: .label)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Stack"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "View 를 레이아웃 하고 이미지를 디코딩 하여 Render Server에 전달 합니다. 2. Commit Transaction 으로 부터 받은 Package를 분석하고 deserialize하여 rendering tree에 보낸다 "
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.layer.cornerRadius = 8
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = Date().toString(format: .YMD)
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.layer.cornerRadius = 4
        return label
    }()
    
    let tagConContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var tagContainer: TagContainer = {
        let container = TagContainer(frame: self.frame, spacing: 10)
        return container
    }()
    
    var tags: [String]? {
        didSet {
            if let tags {
                self.tagContainer.setTagItem(tags)
                let height = self.tagContainer.getCurrentIntrinsicHeight()
                self.tagConContainer.snp.updateConstraints { make in
                    make.height.equalTo(height).priority(.low)
                }
            } else {
                self.tagContainer.removeLaguageTag()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addAutoLayout()
        applyAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    func applyTitleTagSize() {
        let width = titleTagView.getItemWidh()
        let height = titleTagView.getItemHeight()
        titleTagViewWidthAnchor?.constant = width
        titleTagViewHeightAnchor?.constant = height
        titleTagView.updateConstraintsIfNeeded()
    }
    
    private func applyAttributes() {
        let colors: [UIColor] = [.sky_blue, .red, .juhwang, .green, .powder_blue, .purple]
        titleTagView.featureLabel.font = .boldSystemFont(ofSize: 18)
        titleTagView.featureLabel.textColor = .label
        colorline.backgroundColor = colors.randomElement()!
        colorline.layer.cornerRadius = 3
        descriptionLabel.numberOfLines = 3
        dateLabel.textColor = .lightGray
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = dynamicBackground()
    }
    
    
    private var titleTagViewWidthAnchor: NSLayoutConstraint?
    private var titleTagViewHeightAnchor: NSLayoutConstraint?
    
    private func addAutoLayout() {
        [
            colorline,
            titleTagView,
            descriptionLabel,
            dateLabel,
            tagConContainer
        ].forEach { self.contentView.addSubview($0) }
        tagConContainer.addSubview(tagContainer)
        
        colorline.translatesAutoresizingMaskIntoConstraints = false
        
        titleTagView.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        tagConContainer.translatesAutoresizingMaskIntoConstraints = false
        tagContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorline.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            colorline.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorline.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            colorline.widthAnchor.constraint(equalToConstant: 8)
        ])
        
        self.titleTagViewWidthAnchor = titleTagView.widthAnchor.constraint(equalToConstant: 20)
        self.titleTagViewHeightAnchor = titleTagView.heightAnchor.constraint(equalToConstant: 20)
        NSLayoutConstraint.activate([
            titleTagView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleTagView.leadingAnchor.constraint(equalTo: colorline.trailingAnchor, constant: 12),
            titleTagView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),
            titleTagViewWidthAnchor!,
            titleTagViewHeightAnchor!
        ])
            
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleTagView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: colorline.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: tagContainer.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        let constHeightAnchor = tagConContainer.heightAnchor.constraint(equalToConstant: 100)
        constHeightAnchor.priority = .defaultLow
        NSLayoutConstraint.activate([
            tagConContainer.topAnchor.constraint(lessThanOrEqualTo: descriptionLabel.bottomAnchor, constant: 24),
            tagConContainer.leadingAnchor.constraint(equalTo: self.colorline.trailingAnchor, constant: 5),
            tagConContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            constHeightAnchor,
            tagContainer.leadingAnchor.constraint(equalTo: tagConContainer.leadingAnchor),
            tagContainer.trailingAnchor.constraint(equalTo: tagConContainer.trailingAnchor),
            tagContainer.topAnchor.constraint(equalTo: tagConContainer.topAnchor),
            tagContainer.bottomAnchor.constraint(equalTo: tagConContainer.bottomAnchor, constant: -12)
        ])
    }
}
