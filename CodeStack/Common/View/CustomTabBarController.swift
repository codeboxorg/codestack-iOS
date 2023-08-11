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

enum TabBarItem: Int{
    case home = 0
    case problem = 1
    case history = 2
    case mypage = 3
}

class CustomTabBarController: UITabBarController,TabBarDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor.sky_blue
    }
    
    private func setSelectedIndex(for index: Int) {
        self.selectedIndex = index
    }
    
    func setSelectedItem(for vc: TabBarItem){
        setSelectedIndex(for: vc.rawValue)
    }
}
