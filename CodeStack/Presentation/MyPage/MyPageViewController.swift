//
//  MyPageViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/05/23.
//

import UIKit
import SnapKit

class MyPageViewController: UIViewController{
    
    let profileView: ProfileView = {
        let view = ProfileView(frame: .zero)
        view.layer.cornerRadius = 12
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        self.view.backgroundColor = UIColor.systemBackground
    }
    
    private func configure(){
        view.addSubview(profileView)
        profileView.snp.makeConstraints{
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(-44)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(250).priority(.low)
        }
    }
    
    
}
