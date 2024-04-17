//
//  HideButton.swift
//  CommonUI
//
//  Created by 박형환 on 3/6/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit


public final class CommonHideButton: BaseButton {
    
    public enum HideType: Equatable {
        case tagHide(Bool)
        case nameIntroduceHide(Bool)
        
        public mutating func toggle() {
            if case let .tagHide(flag) = self {
                if flag == false {
                    self = .tagHide(true)
                } else {
                    self = .nameIntroduceHide(true)
                }
                return
            }
            
            if case let .nameIntroduceHide(flag) = self {
                if flag == true {
                    self = .nameIntroduceHide(false)
                } else {
                    self = .tagHide(false)
                }
            }
            
        }
    }
    
    private lazy var up = UIImage(systemName: "chevron.up")?
        .resized(withPercentage: 0.9)?
        .withTintColor(dynamicLabelColor)
    
    private lazy var down = UIImage(systemName: "chevron.down")?
        .resized(withPercentage: 0.9)?
        .withTintColor(dynamicLabelColor)
    
    public lazy var hideFlagV2: HideType = .tagHide(false) {
        didSet {
            var image: UIImage?
            
            if case let .tagHide(flag) = oldValue
            {
                image = flag == false ? self.up : self.down
            } 
            else if case let .nameIntroduceHide(flag) = oldValue
            {
                image = flag == false ? self.up : self.down
            }
            
            self.setImage(image, for: .normal)
        }
    }
    public lazy var hideFlag: Bool = false {
        didSet {
            let image = oldValue == false ? self.up : self.down
            self.setImage(image, for: .normal)
        }
    }
    
    public override func applyAttributes() {
        self.imageView?.contentMode = .scaleAspectFit
        self.contentVerticalAlignment = .fill
        self.contentHorizontalAlignment = .fill
        self.setImage(down, for: .normal)
    }
}
