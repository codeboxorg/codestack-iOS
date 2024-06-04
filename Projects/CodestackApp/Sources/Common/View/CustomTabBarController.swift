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

final class CustomTabBarController: UITabBarController, TabBarDelegate, UITabBarControllerDelegate {
    
    public var stepper: RxFlow.Stepper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setValue(CustomTabBar(), forKey: "tabBar")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        #if Dev
        print("TabBarController - View DidLayout Subviews")
        #endif
        
        let frame = tabBar.frame
        
        let origin = CGPoint(
            x: frame.origin.x - 5,
            y: frame.origin.y + 12
        )
        
        let size = CGSize(
            width: frame.size.width + 10,
            height: frame.size.height
        )
        
        tabBar.frame = CGRect(
            origin: origin,
            size: size
        )
    }
    
    func menuButtonAction(action: UIAction) {
        stepper?.steps.accept(CodestackStep.writeSelectStep)
    }
    
    func addTabBarItems() {
        for (item, vc) in zip(UIImage.tabBarItems, viewControllers ?? []) {
            vc.tabBarItem = item
        }
        setUpMiddleButton()
    }
    
    func setSelectedItem(for vc: TabBarItem){
        setSelectedIndex(for: vc.rawValue)
    }
    
    private func setSelectedIndex(for index: Int) {
        self.selectedIndex = index
    }
    
    func setUpMiddleButton() {
        if let tabBar = self.tabBar as? CustomTabBar {
            tabBar.setupMiddleButton(
                self.view.bounds,
                menuButtonAction(action:)
            ) 
            self.view.layoutIfNeeded()
        }
    }
    
//    private func setupMiddleButton() {
//        let image = UIImage(systemName: "plus")!
//            .resize(
//                targetSize: CGSize(
//                    width: 25,
//                    height: 25
//                )
//            )
//        
//        let colorImage = image.imageWithColor(color: .whiteGray).cgImage
//        let width = self.view.bounds.width + 10
//        
//        let button = UIButton(
//            frame: CGRect(
//                x: (width / 2) - 25,
//                y: -20,
//                width: 50,
//                height: 50
//            )
//        )
//        
//        button.layer.cornerRadius = 25
//        button.backgroundColor = .sky_blue
//        
//        button.layer.addImageGradient(contents: colorImage)
//        
//        button.addTarget(
//            self,
//            action: #selector(self.menuButtonAction),
//            for: .touchUpInside
//        )
//        
//        self.tabBar.addSubview(button)
//        self.view.layoutIfNeeded()
//    }
}
