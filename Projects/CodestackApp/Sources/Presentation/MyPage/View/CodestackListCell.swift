//
//  CodestackListCell.swift
//  CodestackApp
//
//  Created by 박형환 on 3/3/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import SnapKit
import UIKit
import Then
import CommonUI

final class CodestackListCell: UITableViewCell {
    
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
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = Date().toString(format: .YMD)
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.layer.cornerRadius = 4
        return label
    }()
    
    let languageBtn: LanguageButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.titlePadding = 5
        let button = LanguageButton().makeLanguageButton()
        button.configuration = configuration
        button.setTitleColor(.label, for: .normal)
        button.setTitle("   ", for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addAutoLayout()
        applyAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let contentViewFrame = self.contentView.frame
        let insetContentViewFrame 
        = contentViewFrame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        self.contentView.frame = insetContentViewFrame
        self.selectedBackgroundView?.frame = insetContentViewFrame
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
            dateLabel,
            languageBtn
        ].forEach { self.contentView.addSubview($0) }
        
        colorline.translatesAutoresizingMaskIntoConstraints = false
        titleTagView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
            
        languageBtn.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(8)
            make.width.equalTo(35).priority(.low)
            make.height.equalTo(35)
        }
    }
}
