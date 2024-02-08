//
//  BaseButton.swift
//  CommonUI
//
//  Created by 박형환 on 2/1/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit


open class BaseButton: UIButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        applyAttributes()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    public override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        layerAttributes()
    }
    
    open func layerAttributes() { }
    
    open func applyAttributes() { }
}


