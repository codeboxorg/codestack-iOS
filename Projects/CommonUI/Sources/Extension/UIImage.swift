//
//  UIImage.swift
//  CommonUI
//
//  Created by 박형환 on 2/25/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit


public extension UIImage {
    
    /// 탭바 이미지 위치를 맞추기 위한 함수
    /// - Parameter size: 이미지 사이즈
    /// - Returns: 이미지
    func baseOffset(size: CGFloat = 12) -> UIImage {
        return self.withBaselineOffset(fromBottom: size)
    }
    
    static var tabBarItems: [UITabBarItem] {
        [
           UITabBarItem(
               title: nil,
               image: UIImage(systemName: "house")?.baseOffset(),
               tag: 0
           ),
           UITabBarItem(
               title: nil,
               image: UIImage(systemName: "list.bullet.rectangle.portrait")?
                   .baseOffset(),
               tag: 1
           ),
           UITabBarItem(
               title: nil,
               image: UIImage().baseOffset(),
               tag: 2
           ),
           UITabBarItem(
               title: nil,
               image: UIImage(systemName: "clock")?.baseOffset(),
               tag: 3
           ),
           UITabBarItem(
               title: nil,
               image: UIImage(systemName: "person")?.baseOffset(),
               tag: 4
           )
       ]
    }
    
    func imageWith(color: UIColor) -> CGImage? {
        imageWithColor(color: color).cgImage
    }
    
    func imageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            self.size,
            false,
            self.scale
        )
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(
            origin: .zero,
            size: CGSize(
                width: self.size.width,
                height: self.size.height
            )
        )
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func resize(targetSize: CGSize) -> UIImage {
         let newRect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height).integral
         return UIGraphicsImageRenderer(size: targetSize).image { v in
             draw(in: newRect)
         }
     }
    
    func compress(to kb: Int, allowedMargin: CGFloat = 0.2) -> Data {
        let bytes = kb * 1024
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        var complete = false
        
        while(!complete) {
            if let data = holderImage.pngData() {
                let ratio = data.count / bytes
                if data.count < Int(CGFloat(bytes) * (1 + allowedMargin)) {
                    complete = true
                    return data
                } else {
                    let multiplier: CGFloat = CGFloat((ratio / 5) + 1)
                    compression -= (step * multiplier)
                }
            }
            guard let newImage = holderImage.resized(withPercentage: compression) else { break }
            holderImage = newImage
        }
        return Data()
    }
    
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
