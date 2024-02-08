//
//  SkeletonView.swift
//  CommonUI
//
//  Created by 박형환 on 1/31/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit

public extension UIView {
    func removeSkeletonViewFromSuperView(_ action: @escaping () -> Void = {} ) {
        self.subviews.forEach {
            for layer in $0.layer.sublayers ?? [] {
                if let name = layer.name {
                    if name == "skeletonGradientName" || name == "skeletonLayerName" {
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
        action()
    }
    
    func removeSkeletonView() {
        for layer in self.layer.sublayers ?? [] {
            if let name = layer.name {
                if name == "skeletonGradientName" || name == "skeletonLayerName" {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
    func addSkeletonAndRemoveView(width: CGFloat = 0,
                                  height: CGFloat = 30,
                                  interval: CGFloat = 0.4) {
        self.addSkeletonView(width: width, height: height)
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.removeSkeletonView()
        }
    }
    
    func addSkeletonView(width: CGFloat = 0, height: CGFloat = 30) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "skeletonGradientName"
        let backgroud = UIColor.init(hexCode: "#D2D2D2").cgColor
        let highlight = UIColor.init(hexCode: "#EBEBEB").cgColor
        let radius = layer.cornerRadius == 0.0 ? self.bounds.width / 8 : layer.cornerRadius
        let colors = [backgroud, highlight, backgroud]
        let caLayer = CALayer()
        caLayer.name = "skeletonLayerName"
        caLayer.cornerRadius = radius
        caLayer.backgroundColor = backgroud
        
        let size =
        self.bounds.size.height < 9
        ?
        CGSize(width: width == 0 ? self.bounds.width : width, height: height)
        :
        CGSize(width: width == 0 ? self.bounds.width : width, height: self.bounds.size.height)
        
        caLayer.frame = CGRect(origin: .zero, size: size)
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.mask = caLayer
        self.layer.cornerRadius = radius
        
        gradientLayer.cornerRadius = radius
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1 , y: 0.5)
        self.layer.addSublayer(caLayer)
        self.layer.addSublayer(gradientLayer)
        
        let colorAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        
        colorAnimation.fromValue =
        NSValue(cgPoint: CGPoint(x: -UIScreen.main.bounds.width, y: gradientLayer.frame.origin.y))
        colorAnimation.toValue =
        NSValue(cgPoint: CGPoint(x: UIScreen.main.bounds.width, y: gradientLayer.frame.origin.y))
        
        colorAnimation.duration = 2
        colorAnimation.autoreverses = false
        colorAnimation.repeatCount = .infinity
        colorAnimation.fillMode = .forwards
        gradientLayer.add(colorAnimation, forKey: "transformAnimation")
    }
}

public extension CALayer {
    
    func addImageGradient(contents: CGImage? = nil, contentSize: CGFloat = 25) {
        let xPoint = (self.bounds.width / 2) - contentSize / 2
        let yPoint = (self.bounds.width / 2) - contentSize / 2
        
        let imageLayer = CALayer()
        imageLayer.contents = contents
        imageLayer.frame = CGRect(origin: CGPoint(x: xPoint, y: yPoint),
                                  size: CGSize(width: contentSize, height: contentSize))
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: self.bounds.size)
        gradientLayer.colors = UIColor.codestackGradient.map(\.cgColor)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1 , y: 0.5)
        
        gradientLayer.addSublayer(imageLayer)
        masksToBounds = true
        addSublayer(gradientLayer)
    }
    
    func addSkeletonLayer(width: CGFloat = 0, height: CGFloat = 30) {
        let backgroud = UIColor.skeletonBack.cgColor
        let highlight = UIColor.skeletonHighlight.cgColor
        
        let radius = cornerRadius == 0.0 ? self.bounds.width / 8 : cornerRadius
        let colors = [backgroud, highlight, backgroud]
        let caLayer = CALayer()
        caLayer.name = "skeletonLayerName"
        caLayer.cornerRadius = radius
        caLayer.backgroundColor = backgroud
        
        let size =
        self.bounds.size.height < 9
        ?
        CGSize(width: width == 0 ? self.bounds.width : width, height: height)
        :
        CGSize(width: width == 0 ? self.bounds.width : width, height: self.bounds.size.height)
        
        caLayer.frame = CGRect(origin: .zero, size: size)
        
        masksToBounds = true
        mask = caLayer
        cornerRadius = radius
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "skeletonGradientName"
        gradientLayer.cornerRadius = radius
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1 , y: 0.5)
        addSublayer(caLayer)
        addSublayer(gradientLayer)
        
        let colorAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        
        colorAnimation.fromValue =
        NSValue(cgPoint: CGPoint(x: -UIScreen.main.bounds.width, y: gradientLayer.frame.origin.y))
        colorAnimation.toValue =
        NSValue(cgPoint: CGPoint(x: UIScreen.main.bounds.width, y: gradientLayer.frame.origin.y))
        
        colorAnimation.duration = 2
        colorAnimation.autoreverses = false
        colorAnimation.repeatCount = .infinity
        colorAnimation.fillMode = .forwards
        gradientLayer.add(colorAnimation, forKey: "transformAnimation")
    }
}


