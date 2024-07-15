//
//  CustomTabBar.swift
//  CommonUI
//
//  Created by 박형환 on 2/1/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit



public final class CustomTabBar: UITabBar {
    
    private var shapeLayer: CALayer?
    public var rotateFlag: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        self.clipsToBounds = false
        self.isTranslucent = false
        self.tintColor = .codestackGradient.first!
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = UIColor.clear
        tabBarAppearance.shadowColor = nil
        self.scrollEdgeAppearance = tabBarAppearance
        self.standardAppearance = tabBarAppearance
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
    }
    
    convenience init(_ bounds: CGRect, _ handler: @escaping (UIAction) -> Void) {
        self.init(frame: .zero)
        setupMiddleButton(bounds, handler)
    }
    
    public required init(coder: NSCoder) {
        fatalError()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.addShape()
    }
    
    public func setupMiddleButton(_ bounds: CGRect, _ handler: @escaping (UIAction) -> Void) {
        let image = UIImage(systemName: "plus")!
            .resize(
                targetSize: CGSize(
                    width: 25,
                    height: 25
                )
            )
        
        let colorImage = image.imageWith(color: .whiteGray)
        let width = bounds.width + 10
        
        let button = UIButton(
            frame: CGRect(
                x: (width / 2) - 25,
                y: -20,
                width: 50,
                height: 50
            )
        )
        
        button.layer.cornerRadius = 25
        button.backgroundColor = .sky_blue
        
        button.layer.addImageGradient(contents: colorImage)
        
        button
            .addAction(
                UIAction(handler: handler),
                for: .touchUpInside
            )
        
        button
            .addAction(
                UIAction(handler: {[weak self, weak button] v in
                    self?.rotateFlag.toggle()
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            button?.transform
                            =
                            (self?.rotateFlag ?? false) ?
                            CGAffineTransform(rotationAngle: CGFloat.pi * 0.25)
                            :
                            CGAffineTransform(rotationAngle: -(CGFloat.pi * 0.5))
                        }
                    )
                }),
                for: .touchUpInside
            )
        
        self.addSubview(button)
    }
    
    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = makeLinePath()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor.systemBackground.cgColor
        shapeLayer.lineWidth = 1.0
        
        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }
    

    public func makeLinePath() -> CGPath {
        let height: CGFloat = 37.0
        let path = UIBezierPath()
        let centerWidth = self.frame.width / 2
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0))
        
        path.addCurve(
            to: CGPoint(x: centerWidth, y: height),
            controlPoint1: CGPoint(x: (centerWidth - 30), y: 0),
            controlPoint2: CGPoint(x: centerWidth - 35, y: height)
        )
        
        path.addCurve(
            to: CGPoint(x: (centerWidth + height * 2), y: 0),
            controlPoint1: CGPoint(x: centerWidth + 35, y: height),
            controlPoint2: CGPoint(x: (centerWidth + 30), y: 0)
        )
        
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()
        
        return path.cgPath
    }
    
    // TODO: 트러블 슈팅 작성 HitTest
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        for member in subviews.reversed() {
            let subPoint = member.convert(point, from: self)
            guard let result = member.hitTest(subPoint, with: event)
            else { continue }
            if result === subviews[2] { return nil }
            return result
        }
        return nil
    }
}

