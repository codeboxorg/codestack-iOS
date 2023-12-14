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
import Data

class LoginViewController: UIViewController,Stepper, AppleLoginViewType {
    
    //MARK: - RXFLow
    let steps = PublishRelay<Step>()
    
    //MARK: -Dependency
    
    private var loginViewModel: (any LoginViewModelProtocol)?
    private var appleManager: AppleLoginManager?
    
    struct Dependencies{
        var viewModel: (any LoginViewModelProtocol)?
        var appleManager: AppleLoginManager?
    }
    
    static func create(with dependencies: Dependencies) -> LoginViewController{
        let vc = LoginViewController()
        vc.loginViewModel = dependencies.viewModel
        vc.appleManager = dependencies.appleManager
        vc.appleManager?.loginViewcontroller = vc
        return vc
    }
    
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var loginView: LoginView = {
        let loginView = LoginView(frame: .zero)
        loginView.translatesAutoresizingMaskIntoConstraints = false
        return loginView
    }()

    //MARK: LoginVC Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutConfigure()
        // Apple login buton setting
        appleManager?.settingLoginView()
        
        let loginEvent = loginView.emitButtonEvents()
        
        let registerEvent = loginView.registerEvent()
        
        let output =
        (loginViewModel as! LoginViewModel)
            .transform(input: LoginViewModel.Input(loginEvent: loginEvent,
                                                  registerEvent: registerEvent))
        
        loginView.binding(loading: output.loading)
    
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.loginView.debugIDPwd()
        })
    }
    
    fileprivate func layoutConfigure(){
        
        view.backgroundColor = .tertiarySystemBackground
        
        self.view.addSubview(contentView)
        contentView.addSubview(loginView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
        
        
        let loginHeightAnchor = loginView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 1.8)
        loginHeightAnchor.priority = .defaultLow
        
        [loginView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 24),
         loginHeightAnchor,
         loginView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
         loginView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12)].forEach{
            $0.isActive = true
        }
        
    }
}



