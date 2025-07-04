//
//  UIImage-extension.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/17.
//

import UIKit


extension UIImage {
//    /// 탭바 이미지 위치를 맞추기 위한 함수
//    /// - Parameter size: 이미지 사이즈
//    /// - Returns: 이미지
//    func baseOffset(size: CGFloat = 12) -> UIImage {
//        return self.withBaselineOffset(fromBottom: size)
//    }
}


struct ImageCompressor {
    
    /// 이미지 압축하는 함수
    /// - Parameters:
    ///   - image: 압출할 이미지
    ///   - maxByte: max 로 이미지 크기 최대치 조정
    ///   - completion: 콜백 함수
    static func compress(image: UIImage, maxByte: Int,
                         completion: @escaping (UIImage?) -> ()) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let currentImageSize = image.jpegData(compressionQuality: 1.0)?.count else {
                return completion(nil)
            }
            
            var iterationImage: UIImage? = image
            var iterationImageSize = currentImageSize
            var iterationCompression: CGFloat = 1.0
        
            while iterationImageSize > maxByte && iterationCompression > 0.01 {
                let percentageDecrease = getPercentageToDecreaseTo(forDataCount: iterationImageSize)
            
                let canvasSize = CGSize(width: image.size.width * iterationCompression,
                                        height: image.size.height * iterationCompression)
                UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
                defer { UIGraphicsEndImageContext() }
                image.draw(in: CGRect(origin: .zero, size: canvasSize))
                iterationImage = UIGraphicsGetImageFromCurrentImageContext()
            
                guard let newImageSize = iterationImage?.jpegData(compressionQuality: 1.0)?.count else {
                    return completion(nil)
                }
                iterationImageSize = newImageSize
                iterationCompression -= percentageDecrease
            }
            completion(iterationImage)
        }
    }

    private static func getPercentageToDecreaseTo(forDataCount dataCount: Int) -> CGFloat {
        switch dataCount {
        case 0..<5000000: return 0.03
        case 5000000..<10000000: return 0.1
        default: return 0.2
        }
    }
}

extension UIImage {
//    func resize(targetSize: CGSize) -> UIImage {
//         let newRect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height).integral
//         return UIGraphicsImageRenderer(size: targetSize).image { v in
//             draw(in: newRect)
//         }
//     }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
            // Determine the scale factor that preserves aspect ratio
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            
            let scaleFactor = min(widthRatio, heightRatio)
            
            // Compute the new image size that preserves aspect ratio
            let scaledImageSize = CGSize(
                width: size.width * scaleFactor,
                height: size.height * scaleFactor
            )

            // Draw and return the resized UIImage
            let renderer = UIGraphicsImageRenderer(
                size: scaledImageSize
            )

            let scaledImage = renderer.image { _ in
                self.draw(in: CGRect(
                    origin: .zero,
                    size: scaledImageSize
                ))
            }
            return scaledImage
        }
    
}

extension UIImage {
//    func imageWithColor(color: UIColor) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(
//            self.size,
//            false,
//            self.scale
//        )
//        color.setFill()
//
//        let context = UIGraphicsGetCurrentContext()
//        context?.translateBy(x: 0, y: self.size.height)
//        context?.scaleBy(x: 1.0, y: -1.0)
//        context?.setBlendMode(CGBlendMode.normal)
//
//        let rect = CGRect(
//            origin: .zero,
//            size: CGSize(
//                width: self.size.width,
//                height: self.size.height
//            )
//        )
//        context?.clip(to: rect, mask: self.cgImage!)
//        context?.fill(rect)
//
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage!
//    }
}
