//
//  CustomScrollView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/24.
//

import UIKit

class CustomScrollView: UIScrollView{
    
    
    override var contentOffset: CGPoint{
        didSet{
            print("contentOffset: \(self.contentOffset)")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
}
