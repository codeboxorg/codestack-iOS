//
//  AppDelegate.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit

extension UIApplication{
    static func getScreenSize() -> CGFloat{
        let firstScene = UIApplication.shared.connectedScenes.first 
        if let scene = firstScene as? UIWindowScene {
            let screenSize = scene.screen.bounds.height
            return screenSize
        }
        return 0
    }
}
