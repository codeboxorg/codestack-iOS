//
//  CustomTabBarController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/13.
//

import UIKit
import SwiftUI
import RxFlow
import CommonUI

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

final class MockViewController: UIViewController {}

final class CustomTabBarController: UITabBarController, TabBarDelegate, UITabBarControllerDelegate {
    
    public var stepper: RxFlow.Stepper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setValue(CustomTabBar(), forKey: "tabBar")
        
        tabBar.clipsToBounds = false
        tabBar.isTranslucent = false
        tabBar.tintColor = .codestackGradient.first!
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = UIColor.clear
        tabBarAppearance.shadowColor = nil
        tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBar.standardAppearance = tabBarAppearance
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = tabBar.frame
        let origin = CGPoint(x: frame.origin.x - 5, y: frame.origin.y + 12)
        let size = CGSize(width: frame.size.width + 10, height: frame.size.height)
        tabBar.frame = CGRect(origin: origin, size: size)
    }
    
    private var tabBarItems: [UITabBarItem] = [
        UITabBarItem(title: nil, image: UIImage(systemName: "house")?.baseOffset(), tag: 0),
        UITabBarItem(title: nil, image: UIImage(systemName: "list.bullet.rectangle.portrait")?.baseOffset(), tag: 1),
        UITabBarItem(title: nil, image: UIImage().baseOffset(), tag: 2),
        UITabBarItem(title: nil, image: UIImage(systemName: "clock")?.baseOffset(), tag: 3),
        UITabBarItem(title: nil, image: UIImage(systemName: "person")?.baseOffset(), tag: 4)
    ]
    
    func addTabBarItems() {
        
        for (item, vc) in zip(tabBarItems, viewControllers ?? []) {
            vc.tabBarItem = item
        }
        
        setupMiddleButton()
    }
    
    func setSelectedItem(for vc: TabBarItem){
        setSelectedIndex(for: vc.rawValue)
    }
    
    private func setSelectedIndex(for index: Int) {
        self.selectedIndex = index
    }
    
    private func setupMiddleButton() {
        let image = UIImage(systemName: "plus")!.resize(targetSize: CGSize(width: 25, height: 25))
        let colorImage = image.imageWithColor(color: .whiteGray).cgImage
        let width = self.view.bounds.width + 10
        let button = UIButton(frame: CGRect(x: (width / 2) - 25, y: -20, width: 50, height: 50))
        button.layer.cornerRadius = 25
        button.backgroundColor = .sky_blue
        
        button.layer.addImageGradient(contents: colorImage)
        button.addTarget(self, action: #selector(self.menuButtonAction), for: .touchUpInside)
        
        self.tabBar.addSubview(button)
        self.view.layoutIfNeeded()
    }
    
    @objc func menuButtonAction(sender: UIButton) {
        stepper?.steps.accept(CodestackStep.writeSelectStep)
    }
}
