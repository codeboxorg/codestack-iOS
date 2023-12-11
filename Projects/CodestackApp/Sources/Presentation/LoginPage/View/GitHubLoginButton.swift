//
//  GitHubLoginButton.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import UIKit

class GitHubLoginButton: UIButton{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(UIImage(named: "github")!, for: .normal)
        self.tintColor = UIColor.white
        self.setTitle("Github 로그인", for: .normal)
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = 8
        self.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    
}
