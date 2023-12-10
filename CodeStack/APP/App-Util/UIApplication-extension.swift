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


extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}
