//
//  WritePostingView+Binder.swift
//  CodestackApp
//
//  Created by 박형환 on 4/30/24.
//  Copyright © 2024 com.hwan. All rights reserved.
//

import UIKit
import SnapKit
import SwiftDown
import SwiftUI
import RxSwift

extension WritePostingView {
    
    func makeSwiftDownView() -> UIView {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            let v = SwiftDownEditor(text: $viewModel.content)
                .theme(.BuiltIn.defaultDark.theme())
                .insetsSize(15)
                .tint(.white)
            return UIHostingController(rootView: v).view
        }
        else {
            let v = SwiftDownEditor(text: $viewModel.content)
                .theme(.BuiltIn.defaultLight.theme())
                .insetsSize(15)
                .tint(.white)
            return UIHostingController(rootView: v).view
        }
    }
    
    var binder: Binder<UserInterface> {
        Binder<UserInterface>(self) { view, value in
        }
    }
}

