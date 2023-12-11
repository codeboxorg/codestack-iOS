//
//  UIButton.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import UIKit


typealias SendButton = UIButton
typealias HideButton = UIButton
typealias LanguageButton = UIButton
typealias PopUpcontainer = UIView
typealias FavoriteButton = UIButton

final class HeartButton: FavoriteButton {
    
    var flag: Bool = false {
        didSet {
            self.flag ?
            self.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            :
            self.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView?.contentMode = .scaleAspectFit
        self.contentVerticalAlignment = .fill
        self.contentHorizontalAlignment = .fill
        self.setImage(UIImage(systemName: "heart"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIButton {
    
    /// Send Button Attribute Setting
    func applySubmitAttrubutes(title: String = "제출하기") {
        var configuration = UIButton.Configuration.plain()
        configuration.titlePadding = 10
        self.configuration = configuration
        self.setTitle("\(title)", for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.tintColor = .label
        self.layer.borderColor = UIColor.sky_blue.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }
    
    func makeHideButton(height: CGFloat) -> HideButton {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.backgroundColor = UIColor.clear
//        button.layer.borderColor = UIColor.powder_blue.cgColor
//        button.layer.borderWidth = 1
        button.layer.cornerRadius = height / 2
        return button
    }
    
    func makeLanguageButton() -> LanguageButton {
        var config: UIButton.Configuration = .plain()
        config.buttonSize = .small
        config.titleLineBreakMode = .byClipping
        config.titlePadding = 5
        let button = LanguageButton(configuration: config)
        
        button.layer.borderColor = UIColor.sky_blue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        return button
    }
}


