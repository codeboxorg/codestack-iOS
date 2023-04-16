//
//  HighlightButton.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit


class HighlightButton: UIButton{

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
    private func layoutConfigure(){
        var configuration = UIButton.Configuration.plain()
        configuration.titlePadding = 10
        self.configuration = configuration
        self.layer.borderColor = UIColor.systemBlue.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        self.setTitleColor(.white, for: .highlighted)
        self.setTitleColor(.systemBlue, for: .normal)
    }
}
