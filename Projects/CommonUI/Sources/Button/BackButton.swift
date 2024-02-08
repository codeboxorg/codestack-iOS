//
//  BackButton.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/07.
//

import UIKit


public final class BackButton: UIButton{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        self.tintColor = UIColor.systemGray
        self.imageView?.contentMode = .scaleAspectFill
    }
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
}
