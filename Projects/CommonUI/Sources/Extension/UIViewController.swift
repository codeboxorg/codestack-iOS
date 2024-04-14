//
//  UIViewController.swift
//  CommonUI
//
//  Created by 박형환 on 3/4/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit

public extension UIViewController {
    func makeSFSymbolButton(_ target: Any?, action: Selector, symbolName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbolName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tintColor = .sky_blue
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        return barButtonItem
    }
}

public extension UIView {
    func makeSFSymbolButton(_ target: Any?, action: Selector, symbolName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbolName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tintColor = .sky_blue
        return button
    }
    
    func makeSFSymbolButton(symbolName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbolName), for: .normal)
        button.tintColor = .sky_blue
        return button
    }
}



