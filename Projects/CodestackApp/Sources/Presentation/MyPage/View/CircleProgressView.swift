//
//  CircleProgressView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/25.
//

import UIKit
import Global

class CircleProgressView: UIView {
    
    public var progressColor: UIColor? {
        didSet {
            circleLayer.progressColor = progressColor
            circleLayer.setNeedsDisplay()
        }
    }
    
    public var progressBackgroundColor: UIColor? {
        didSet {
            circleLayer.progressBackgroundColor = progressBackgroundColor
            circleLayer.setNeedsDisplay()
        }
    }
    
    public var progress: CGFloat = 0 {
        didSet {
            circleLayer.progress = progress
            circleLayer.setNeedsDisplay()
        }
    }
    
    public var progressWidth: CGFloat = 0 {
        didSet {
            circleLayer.progressWidth = progressWidth
            circleLayer.setNeedsDisplay()
        }
    }
    
    public var clockwise: Bool {
        set {
            circleLayer.clockwise = !newValue
            circleLayer.setNeedsDisplay()
        }
        get {
            return !circleLayer.clockwise
        }
    }
    
    private var circleLayer: CircleLayer {
        return layer as! CircleLayer
    }
    
    public override class var layerClass: AnyClass {
        return CircleLayer.self
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .tertiarySystemBackground
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func configureAttributes(color: UIColor,
                                    background: UIColor,
                                    progress: CGFloat,
                                    clockwise: Bool = false){
        self.progressColor = color
        self.progressBackgroundColor = background
        self.progress = progress
        self.clockwise = clockwise
        
    }
    
    public func startProgressAnimate() {
        circleLayer.animate()
    }
}
