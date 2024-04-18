//
//  ColorMode.swift
//  CommonUI
//
//  Created by 박형환 on 2/1/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit


extension UITraitEnvironment {
    public func dynamicBackground() -> UIColor {
        UIColor(dynamicProvider: { trait in
            if trait.userInterfaceStyle == .dark {
                return .tertiarySystemBackground
            } else {
                return .whiteGray
            }
        })
    }
    
    public var dynamicLabelColor: UIColor {
        UIColor(dynamicProvider: { trait in
            if trait.userInterfaceStyle == .dark {
                return .whiteGray
            } else {
                return .black
            }
        })
    }
    
    public var dynamicSysBackground: UIColor {
        UIColor(dynamicProvider: { trait in
            if trait.userInterfaceStyle == .dark {
                return .systemBackground
            } else {
                return .whiteGray
            }
        })
    }
}





