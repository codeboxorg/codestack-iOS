//
//  HideButton.swift
//  CommonUI
//
//  Created by 박형환 on 3/6/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit


public final class CommonHideButton: BaseButton {
    
    convenience init(action: ((Bool) -> Void)? = nil) {
        self.init(frame: .zero)
        self.action = action
    }
    
    private lazy var up = UIImage(systemName: "chevron.up")?
        .resized(withPercentage: 0.9)?
        .withTintColor(dynamicLabelColor)
    
    public lazy var hideFlag: Bool = false {
        didSet {
            action?(!oldValue)
            UIView.animate(
                withDuration: 0.3,
                animations: { [weak self] in
                    self?.transform
                    =
                    (self?.hideFlag ?? false) ?
                    CGAffineTransform(rotationAngle: CGFloat.pi * 0.999)
                    :
                    CGAffineTransformIdentity
                }
            )
        }
    }
    
    public var action: ((Bool) -> Void)?
    
    public override func applyAttributes() {
        self.imageView?.contentMode = .scaleAspectFit
        self.contentVerticalAlignment = .fill
        self.contentHorizontalAlignment = .fill
        self.setImage(up, for: .normal)
    }
}
