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
    
    func makeHideButton(height: CGFloat) -> HideButton {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.backgroundColor = UIColor.clear
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


