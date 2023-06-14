//
//  ViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import SnapKit
import RxFlow
import RxSwift
import RxRelay

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

typealias HomeViewController = ViewController
class ViewController: UIViewController {
    
//    weak var delegate: SideMenuDelegate?
    
    private var homeViewModel: (any HomeViewModelProtocol)?
    
    static func create(with dependencies: any HomeViewModelProtocol) -> ViewController{
        let vc = ViewController()
        vc.homeViewModel = dependencies
//        vc.navigationSetting()
        return vc
    }
    
    private lazy var mainView: MainView = {
        let view = MainView(frame: .zero, stepType: [.problemList,.fakeStep])
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()
        layoutConfigure()
        print("ViewController - viewDidLoad")
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//            self.mainView.move()
        })
        #endif
        
        _ = (homeViewModel as! HomeViewModel)
            .transform(input: HomeViewModel.Input(problemButtonEvent: mainView.emitButtonEvents()))
    }
    
    
    func navigationSetting(){
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
        print(self.navigationItem)
        print(self.navigationController)
    }
    
    
    @objc func rightBarButtonMenuTapped(_ sender: UIBarButtonItem){
//        delegate?.menuButtonTapped()
    }
    
    
    private func layoutConfigure(){
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints{
            $0.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    
    
}

