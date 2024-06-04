//
//  HighlightButton.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit


/// 강조 버튼 component
/// Tap 하면 -> color 변경
public final class HighlightButton: UIButton {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        layoutConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")   
    }
    
    private func layoutConfigure(){
        var configuration = UIButton.Configuration.plain()
        configuration.titlePadding = 10
        self.backgroundColor = .tertiarySystemBackground
        self.tintColor = UIColor.white
        self.configuration = configuration
        self.layer.borderColor = UIColor.whiteGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        self.setTitleColor(.sky_blue, for: .highlighted)
        self.setTitleColor(.label, for: .normal)
    }
}
