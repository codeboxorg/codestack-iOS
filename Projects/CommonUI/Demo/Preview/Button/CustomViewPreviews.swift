

import SwiftUI
import UIKit
import CommonUI


@available(iOS 17.0, *)
#Preview {
    let vc = _TabBarController()
    return vc.showPreview()
        .onAppear {
            vc.setViewControllers(
                [
                    MockViewController()
                        .set(color: .sky_blue),
                    MockViewController()
                        .set(color: .skeletonBack),
                    MockViewController()
                        .set(color: .juhwang),
                    MockViewController()
                        .set(color: .whiteGray),
                    MockViewController()
                        .set(color: .systemGreen)
                ],
                animated: false
            )
            vc.addTabBarItems()
        }
}

final class _TabBarController: UITabBarController, UITabBarControllerDelegate {

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
        print("preview Tapped")
    }
    
    func addTabBarItems() {
        for (item, vc) in zip(UIImage.tabBarItems, viewControllers ?? []) {
            vc.tabBarItem = item
        }
        setUpMiddleButton()
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
}

