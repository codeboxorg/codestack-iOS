//
//  CustomTabBarController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/13.
//

import UIKit

class CustomTabBarController: UITabBarController{
    
    
    struct TabBarItem {
        let homeVC: UIViewController
        let problemVC: UIViewController
        let historyVC: UIViewController
        let myPageVC: UIViewController
    }
    
    private var items: TabBarItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarItem = UITabBarItem(title: "홈", image: UIImage(named: "house"), tag: 0)
        self.tabBarItem = UITabBarItem(title: "문제", image: UIImage(named: "list.bullet.rectangle.portrait"), tag: 1)
        self.tabBarItem = UITabBarItem(title: "기록", image: UIImage(named: "clock"), tag: 2)
        self.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(named: "person"), tag: 3)
        
        guard let items else { Log.error("Item nil"); return }
        
        setViewControllers([items.homeVC,
                            items.problemVC,
                            items.historyVC,
                            items.myPageVC], animated: true)
        
    }
    
    func setViewControllers(items: TabBarItem){
        self.items = items
    }
}
