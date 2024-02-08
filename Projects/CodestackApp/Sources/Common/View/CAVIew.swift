//
//  CAVIew.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/28.
//

import UIKit



class CAView: UIView, CAAnimationDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
    let circleLayer: CAShapeLayer = CAShapeLayer()
    
    var startAngle: CGFloat = (-(.pi) / 2)
    var endAngle: CGFloat = 0.0
    let values: [CGFloat] = [10, 20, 50, 70, 80, 90, 100]
    var currentIndex: Int = 0
    var myCenter = CGPoint.zero
    
    let colors = [UIColor.orange, UIColor.systemYellow, UIColor.systemGreen, UIColor.systemPink, UIColor.cyan, UIColor.systemTeal, UIColor.systemIndigo, UIColor.systemPurple]
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: .zero, y: rect.height))
        
//        path.addCurve(to: CGPoint(x: rect.width, y: rect.height), controlPoint1: CGPoint(x: 0, y: rect.height), controlPoint2: CGPoint(x: rect.width, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: rect.height), controlPoint: CGPoint(x: rect.width / 2,
                                                                                            y: .zero))
        
        path.lineWidth = 5
        UIColor.orange.setStroke()
        path.stroke()
        
    }
    
    
    func startAnimation() {
        let value = self.values[currentIndex]
        let total = values.reduce(0, +)
        self.endAngle = (value / total) * (.pi * 2)
        let path = UIBezierPath(arcCenter: self.myCenter, radius: 100, startAngle: self.startAngle, endAngle: self.startAngle + self.endAngle, clockwise: true)
        
        let sliceLayer = CAShapeLayer()
        sliceLayer.path = path.cgPath
        sliceLayer.fillColor = nil
        sliceLayer.strokeColor = self.colors.randomElement()?.cgColor
        sliceLayer.lineWidth = 100
        sliceLayer.strokeEnd = 1
        self.layer.addSublayer(sliceLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 2
        
        animation.delegate = self
        sliceLayer.add(animation, forKey: animation.keyPath)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let isFinished = flag
        if isFinished && currentIndex < self.values.count - 1 {
            self.currentIndex += 1
            self.startAngle += endAngle
            self.startAnimation()
        }
    }
//    override func draw(_ rect: CGRect) {
//        let layer = CAShapeLayer()
        
//        let path = UIBezierPath()
//
//        path.move(to: rect.origin)
//
//
//        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
//
//        layer.path = path.cgPath
//        layer.lineWidth = 20
//
//        let animation = CABasicAnimation(keyPath: "strokeColor")
//        animation.fromValue = UIColor.black.cgColor
//        animation.toValue = UIColor.yellow.cgColor
//        animation.duration = 2
//
//        layer.strokeColor = UIColor.white.cgColor
//
//        layer.add(animation, forKey: "strokeColor")
        
//        let layer = CAShapeLayer ()
//        let path = UIBezierPath(ovalIn: rect)
//        layer.path = path.cgPath
//        let animation = CABasicAnimation(keyPath: "fillColor")
//        animation.fromValue = UIColor.black.cgColor
//        animation.toValue = UIColor.systemYellow.cgColor
//        animation.duration = 2
//
//        layer.add(animation, forKey: "fillColor")
//        layer.fillColor = UIColor.systemYellow.cgColor
//
//        self.layer.addSublayer(layer)
        
//    }
    
    
//    func addAnimation(from: CGFloat,to: CGFloat){
//        let caLayer = CAShapeLayer()
//
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.fromValue = from
//        animation.toValue = to
//        animation.duration = 1
//        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//
//        caLayer.add(animation, forKey: "strokeEnd")
//    }
}
