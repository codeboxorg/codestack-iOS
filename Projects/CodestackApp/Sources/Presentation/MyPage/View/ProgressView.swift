//
//  ProgressView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/25.
//

import UIKit




class ProgressView: UIProgressView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskLayerPath = UIBezierPath(roundedRect: bounds,cornerRadius: self.frame.height / 2)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskLayerPath.cgPath
        layer.mask = maskLayer
    }
}
