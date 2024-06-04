//
//  UIView.swift
//  CommonUI
//
//  Created by 박형환 on 3/5/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit


private struct FeedBack {
    static var feedBack: UIImpactFeedbackGenerator {
        UIImpactFeedbackGenerator(style: .medium)
    }
}

public extension UIView {
    func feedBackGenerate(){
        FeedBack.feedBack.impactOccurred()
    }
    
    func impact() {
        FeedBack.feedBack.impactOccurred()
    }
}


