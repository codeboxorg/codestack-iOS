//
//  CustomTabBarController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/13.
//

import UIKit
import SwiftUI


protocol TabBarDelegate: AnyObject{
    func setSelectedItem(for vc: TabBarItem)
}

enum TabBarItem: Int {
    case home = 0
    case problem = 1
    case codeStack = 2
    case history = 3
    case mypage = 4
}

class CustomTabBarController: UITabBarController,TabBarDelegate{
    
    var borderView: UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        tabBar.tintColor = .sky_blue
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        tabBarAppearance.shadowColor = nil
        
        tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBar.standardAppearance = tabBarAppearance
    }
    
    private func setSelectedIndex(for index: Int) {
        self.selectedIndex = index
    }
    
    func setSelectedItem(for vc: TabBarItem){
        setSelectedIndex(for: vc.rawValue)
    }
}
