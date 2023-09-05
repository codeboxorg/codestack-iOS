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

extension UIButton{
    
    func makeSendButton(title: String = "제출하기") -> SendButton{
        var configuration = UIButton.Configuration.plain()
        configuration.titlePadding = 10
        let view = SendButton(configuration: configuration)
        view.setTitle("\(title)", for: .normal)
        view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        view.tintColor = .label
        view.layer.borderColor = UIColor.juhwang_2.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        return view
    }
    
    
    func makeHideButton(height: CGFloat) -> HideButton{
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.backgroundColor = UIColor.black
        button.layer.cornerRadius = height / 2
        return button
    }
    
    func makeLanguageButton() -> LanguageButton{
        let button = LanguageButton()
        button.layer.borderColor = UIColor.juhwang_2.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        return button
    }
}


