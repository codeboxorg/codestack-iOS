//
//  PostingTitleView.swift
//  CommonUI
//
//  Created by 박형환 on 2/1/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit


public struct WriterInfo {
    public let title: String
    public let writer: String
    public let date: String
    public var image: UIImage
    
    public init(title: String, writer: String, date: String, image: UIImage) {
        self.title = title
        self.writer = writer
        self.date = date
        self.image = image
    }
    
    public static var mock: Self {
        .init(title: "TestTestTestTest",
              writer: "TestWriter입니다",
              date: "2012-12-12",
              image: UIImage(systemName: "circle") ?? UIImage())
    }
    
    public var isMock: Bool {
        self.writer == "TestWriter입니다"
    }
}

public final class PostingTitleView: BaseView {
    
    public let titleLabel = UILabel()
    public let writerLabel = UILabel()
    public let dateLabel = UILabel()
    public let profileImageView = UIImageView()
    
    public override func applyAttributes() {
        let descriptor = titleLabel.create_descriptor(style: .title1)
        titleLabel.font = UIFont(descriptor: descriptor, size: 28)
        writerLabel.font = UIFont.boldSystemFont(ofSize: 13)
        dateLabel.font = UIFont.boldSystemFont(ofSize: 13)
        
        titleLabel.layer.cornerRadius = 12
        writerLabel.layer.cornerRadius = 4
        
        titleLabel.textColor = .label
        writerLabel.textColor = .label
        dateLabel.textColor = .lightGray
        
        titleLabel.numberOfLines = 0
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 25
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.sky_blue.cgColor
    }
    
    public func apply(_ viewmodel: WriterInfo) {
        self.titleLabel.text = viewmodel.title
        self.writerLabel.text = viewmodel.writer
        self.dateLabel.text = viewmodel.date
        self.profileImageView.image = viewmodel.image
    }
    
    public override func addAutoLayout() {
        [
            titleLabel,
            writerLabel,
            dateLabel,
            profileImageView
        ].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            writerLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            writerLabel.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -4),
            
            dateLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            dateLabel.topAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 4),
        ])
    }
}
