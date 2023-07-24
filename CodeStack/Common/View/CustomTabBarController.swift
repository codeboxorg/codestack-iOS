//
//  CustomTabBarController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/13.
//

import UIKit


protocol TabBarDelegate: AnyObject{
    func setSelectedIndex(for index: Int)
}

class CustomTabBarController: UITabBarController,TabBarDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor.sky_blue
    }
    
    func setSelectedIndex(for index: Int) {
        self.selectedIndex = index
    }
}
