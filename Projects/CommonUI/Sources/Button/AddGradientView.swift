//
//  AddGradientView.swift
//  CommonUI
//
//  Created by 박형환 on 2/1/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit


public final class AddGradientView: BaseButton {
    public override func applyAttributes() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .semibold)
        let image = UIImage(systemName: "plus.circle", withConfiguration: imageConfig)
        setImage(image, for: .normal)
        tintColor = .codestackGradient[1]
    }
}


