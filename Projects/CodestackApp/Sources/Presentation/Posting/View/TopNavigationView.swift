//
//  TopNavigationView.swift
//  CodestackApp
//
//  Created by 박형환 on 3/5/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import CommonUI
import SnapKit
import Then
import UIKit

final class TopNavigationView: BaseView {
    
    lazy var dismissButton: UIButton = makeSFSymbolButton(symbolName: "xmark")
    
    private(set) lazy var sendButton: LoadingUIButton = {
        var button = LoadingUIButton(frame: .zero, title: "저장하기")
        button.addTarget(self, action: #selector(button.feedBackGenerate(_:)), for: .touchUpInside)
        return button
    }()
    
    override func addAutoLayout() {
        self.addSubview(dismissButton)
        self.addSubview(sendButton)
        
        dismissButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(60)
            make.leading.equalToSuperview().inset(12)
            make.width.height.equalTo(30)
        }
        sendButton.snp.makeConstraints { make in
            make.centerY.equalTo(dismissButton)
            make.trailing.equalToSuperview().inset(12)
            make.width.equalTo(sendButton.sendButtonWidth)
            make.height.equalTo(sendButton.sendButtonHeight)
            make.bottom.equalToSuperview().inset(12).priority(.high)
        }
    }
    
    override func applyAttributes() {
        sendButton.tintColor = .label
        sendButton.layer.borderColor = UIColor.sky_blue.cgColor
        sendButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
        sendButton.setTitleColor(dynamicLabelColor, for: .normal)
        sendButton.layer.borderWidth = 0
        sendButton.tintColor = .whiteGray
        sendButton.buttonColor = .whiteGray
    }
    
    
}
