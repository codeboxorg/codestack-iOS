//
//  PlusMinusButton.swift
//  CommonUI
//
//  Created by 박형환 on 6/17/24.
//  Copyright © 2024 com.hwan. All rights reserved.
//

import UIKit

public final class RotateButton: BaseButton {
    
    private(set) var rotateFlag: Bool = false
    
    convenience init(frame: CGRect = .zero, width: CGFloat, height: CGFloat) {
        self.init(frame: frame)
        let image = UIImage(systemName: "plus")!
            .resize(targetSize: CGSize(width: width, height: height))
            .withTintColor(self.dynamicLabelColor)
        self.setImage(image, for: .normal)
    }
    
    public override func applyAttributes() {
        self
            .addAction(
                UIAction(handler: {[weak self] v in
                    self?.rotateFlag.toggle()
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            self?
                                .transform
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
    }
    
}
//public lazy var tagAddButton: UIButton = {
//    let button = UIButton()
//    let image = UIImage(systemName: "plus")!
//        .resize(targetSize: CGSize(width: 20, height: 18))
//        .withTintColor(self.dynamicLabelColor)
//    button
//        .addAction(
//            UIAction(handler: {[weak button] v in
//                UIView.animate(
//                    withDuration: 0.3,
//                    animations: {
//                        button?
//                            .transform
//                        = CGAffineTransform(rotationAngle: CGFloat.pi * 0.25)
//                    }
//                )
//            }),
//            for: .touchUpInside
//        )
//    button.setImage(image, for: .normal)
//    return button
//}()
