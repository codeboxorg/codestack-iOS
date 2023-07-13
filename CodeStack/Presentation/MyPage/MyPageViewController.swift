//
//  MyPageViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/05/23.
//

import UIKit
import SnapKit

class MyPageViewController: UIViewController{
    
    
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    let profileView: ProfileView = {
        let view = ProfileView(frame: .zero)
        view.layer.cornerRadius = 12
        return view
    }()
    
    let statusView: StatusView = {
        let view = StatusView(frame: .zero)
        view.layer.cornerRadius = 12
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        self.view.backgroundColor = UIColor.systemBackground
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
            self.statusView.circleProgressView.startProgressAnimate()
            self.statusView.settingProgressViewAnimation(0.3, 0.6, 0.9)
        })
    }
    
    private func configure(){
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        [profileView,statusView].forEach{
            containerView.addSubview($0)
        }
        
        scrollView.snp.makeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(-44)
        }
        
        
        containerView.snp.makeConstraints{
            $0.top.leading.bottom.trailing.equalToSuperview()
            $0.width.equalTo(self.view.snp.width)
            $0.height.equalTo(500).priority(.low)
        }
        
        profileView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(250).priority(.low)
        }
        
        statusView.snp.makeConstraints{
            $0.top.equalTo(profileView.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(300).priority(.low)
        }
        
    }
    
    
}
