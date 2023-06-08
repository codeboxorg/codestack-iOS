//
//  LoginViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/24.
//

import UIKit
import RxFlow
import RxCocoa
import RxSwift

class LoginViewController: UIViewController,Stepper{
    
    
    //MARK: - RXFLow
    let steps = PublishRelay<Step>()
    
    //MARK: -Dependency
    private var loginViewModel: (any LoginViewModelProtocol)?
    var appleLoginService: AppleLoginManager?
    
    struct Dependencies{
        var viewModel: (any LoginViewModelProtocol)?
    }
    
    static func create(with dependencies: Dependencies) -> LoginViewController{
        let vc = LoginViewController()
        vc.loginViewModel = dependencies.viewModel
        vc.appleLoginService = AppleLoginManager(vc)
        return vc
    }
    
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var loginView: LoginView = {
        let loginView = LoginView(frame: .zero,dependencies: self.loginViewModel)
        loginView.translatesAutoresizingMaskIntoConstraints = false
        return loginView
    }()

    //MARK: LoginVC Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        layoutConfigure()
        // Apple login buton setting
        appleLoginService?.settingLoginView()
        
        let loginEvent = loginView.emitButtonEvents()
        
        _ = (loginViewModel as! LoginViewModel).transform(input: LoginViewModel.Input(loginEvent: loginEvent))
        
        
        //원래 main으로 가는 화면이동 코드
//        loginView.moveTomain = { [weak self] in
//            guard let self else {return}
//            self.navigationController?.pushViewController(containerViewController, animated: true)
//        }
        
        #if DEBUG
        DispatchQueue.main.async {
//            self.loginView.moveTomain?()
        }
        #endif
        
    }
    
    fileprivate func layoutConfigure(){
        
        view.backgroundColor = .tertiarySystemBackground
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(loginView)
        
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
        
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
        
        [loginView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 24),
         loginView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 1.8),
         loginView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
         loginView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50)].forEach{
            $0.isActive = true
        }
        
        loginView.containerViewLayoutIfNeeded()
    }
}



