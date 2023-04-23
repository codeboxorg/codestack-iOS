//
//  ViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import SnapKit


extension UINavigationController{
    
}

extension UIViewController {
    func adjustLargeTitleSize() {
        self.title = "CodeStack"
        self.navigationController?.navigationBar.tintColor = UIColor.label
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        
    }
}

class ViewController: UIViewController {
    
    
    weak var delegate: SideMenuDelegate?
    private var barButtonImage: UIImage?
    
    private lazy var mainView: MainView = {
        let view = MainView(frame: .zero, delegate: delegate)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()
        layoutConfigure()
        
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.mainView.move()
        })
        #endif
    }
    
    
    private func navigationSetting(){
        //라지 타이틀 적용
        adjustLargeTitleSize()
        
        // 사이드바 보기 버튼 적용
        self.view.backgroundColor = UIColor.systemBackground
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(rightBarButtonMenuTapped(_:)))
        
        // back navigtion 백버튼 타이틀 숨기기
        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backButtonAppearance = backButtonAppearance
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
    }
    
    
    @objc func rightBarButtonMenuTapped(_ sender: UIBarButtonItem){
        delegate?.menuButtonTapped()
    }
    
    
    private func layoutConfigure(){
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints{
            $0.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    
    
}

