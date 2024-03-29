//
//  ViewController-ContributionGraph.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/19.
//

import UIKit
import SwiftUI

extension UIViewController {
    func adjustLargeTitleSize(title: String = "Codestack") {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.tintColor = UIColor.label
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
    }
}

extension HomeViewController {
    
    
    func sideMenuVCSetting() {
        // SideMenu ViewController setting
        if let sidemenuViewController {
            addChild(sidemenuViewController)
            view.addSubview(sidemenuViewController.view)
            sidemenuViewController.didMove(toParent: self)
            sidemenuViewController.view.translatesAutoresizingMaskIntoConstraints = false
            sidemenuViewController.view.isHidden = true
            NSLayoutConstraint.activate([
                sidemenuViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                sidemenuViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                sidemenuViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                sidemenuViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private var titleTextAttributesColor: UIColor { .clear }
    
    func navigationSetting(){
        //라지 타이틀 적용
        adjustLargeTitleSize()
        
        // TODO: 추후 Notification 적용시 추가
        // self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: alramView)
        // 사이드바 보기 버튼 적용
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: nil)
        
        // back navigtion 백버튼 타이틀 숨기기
        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: titleTextAttributesColor]
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backButtonAppearance = backButtonAppearance
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
    }
}
