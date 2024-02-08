//
//  RegisterButton.swift
//  CodestackApp
//
//  Created by 박형환 on 1/19/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit

public final class RegisterButton: UIButton {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
    public let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    public convenience init(title: String) {
        self.init(frame: .zero)
        // self.tintColor = CColor.whiteGray.color
        self.setTitle("\(title)", for: .normal)
        self.setTitleColor(CColor.black.color, for: .normal)
        self.backgroundColor = CColor.whiteGray.color
        self.layer.borderColor = CColor.black.color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 12
        activityIndicator.color = .lightGray
        
        self.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isHidden = true
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 30),
            activityIndicator.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
