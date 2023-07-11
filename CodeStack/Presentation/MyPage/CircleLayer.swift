//
//  CircleLayer.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/25.
//

import UIKit




struct Degrees{
    var radians: CGFloat = 0
    var degree: CGFloat
    
    public func toRadians() -> CGFloat {
        return .pi * degree / 180
   }
    
    public func toDegrees() -> CGFloat {
        return radians * 180 / .pi
    }
}

typealias Radians = CGFloat

class CircleLayer: CALayer {
    
    var progressWidth: CGFloat = 0
    var progressColor: UIColor?
    var progressBackgroundColor: UIColor?
    var progress: CGFloat = 1
    var clockwise: Bool = false
    var progressLayer: CAShapeLayer?
    
    var center: CGPoint {
        return CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
    }
    var radius: CGFloat {
        return min(frame.size.width, frame.size.height) / 2
    }
    private let startAngle: Radians = Degrees(degree: 0).toRadians()
    private let endAngle: Radians = Degrees(degree: 360).toRadians()
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        addCenterCircle(ctx)
        addProgressBackground(ctx)
        
        if progressLayer == nil {
            let progressLayer = CAShapeLayer()
            self.progressLayer = progressLayer
        
            setProgressLayerStyle()
            addSublayer(progressLayer)
        } else {
            setProgressLayerStyle()
        }
    }
    
    private func addCenterCircle(_ ctx: CGContext) {
        ctx.addArc(center: center, radius: radius - progressWidth / 2, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.fillPath()
    }
    
    private func addProgressBackground(_ ctx: CGContext) {
        ctx.addArc(center: center, radius: radius - progressWidth / 2,
                                startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        ctx.setLineWidth(progressWidth)
        ctx.setStrokeColor(progressBackgroundColor?.withAlphaComponent(0.3).cgColor ?? UIColor.white.cgColor)
        ctx.strokePath()
        ctx.fillPath()
    }
    
    private func setProgressLayerStyle() {
        progressLayer?.path = UIBezierPath(arcCenter: center, radius: radius - progressWidth / 2, startAngle: startAngle - Degrees(degree: 90).toRadians(), endAngle: endAngle - Degrees(degree: 90).toRadians(), clockwise: clockwise).cgPath
        progressLayer?.lineCap = .round
        progressLayer?.lineWidth = progressWidth
        progressLayer?.fillColor = UIColor.clear.cgColor
        progressLayer?.strokeColor = progressColor?.cgColor
        progressLayer?.strokeStart = 0
        progressLayer?.strokeEnd = progress
        progressLayer?.setNeedsDisplay()
    }
    
    func animate() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = progress
        animation.repeatCount = 1
        animation.duration = 0.7
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        progressLayer?.add(animation, forKey: "StrokeAnimation")
    }
}
