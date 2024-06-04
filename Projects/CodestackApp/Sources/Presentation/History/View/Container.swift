//
//  Container.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/18.
//

import UIKit



class HistoryContainer: UIView{
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.addBorder(side: .top, thickness: 1, color: UIColor.lightGray.cgColor)
        self.layer.addBorder(side: .bottom, thickness: 1, color: UIColor.lightGray.cgColor)
    }
    
}
