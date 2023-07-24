//
//  FoldView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/05/04.
//

import UIKit
import RxCocoa
import RxSwift

class FoldButton: UIButton{
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(UIImage(systemName: "chevron.down"), for: .selected)
        self.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
}
