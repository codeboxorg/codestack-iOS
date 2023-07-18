//
//  Container.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/18.
//

import UIKit



class ContainerView: UIView{
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
    override func draw(_ rect: CGRect) {
        
        let rect = rect
        let path = UIBezierPath()
        
        path.lineWidth = 1
        
        path.move(to: CGPoint(x: 0, y: rect.origin.y))
        path.addLine(to: CGPoint(x: rect.width, y: rect.origin.y))
        path.addLine(to: CGPoint(x: rect.width, y: rect.origin.y + rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.origin.y + rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.origin.y))
        
        UIColor.lightGray.setStroke()
        path.stroke()
    }
    
}
