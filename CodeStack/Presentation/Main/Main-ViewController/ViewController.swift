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
    
    private let mainView: MainView = {
        let view = MainView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()
        layoutConfigure()
    }
    
    
    private func navigationSetting(){
        adjustLargeTitleSize()
        self.view.backgroundColor = UIColor.systemBackground
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(rightBarButtonMenuTapped(_:)))
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

