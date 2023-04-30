//
//  LoginViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/24.
//

import UIKit



class LoginViewController: UIViewController{
    
    //MARK: -Dependency
    var loginViewModel: LoginViewModelProtocol?
    weak var appleLoginManager: AppleLoginManager?
    
    struct Dependencies{
        var viewModel: LoginViewModelProtocol?
    }
    
    static func create(with dependencies: Dependencies) -> LoginViewController{
        let vc = LoginViewController()
        vc.loginViewModel = dependencies.viewModel
        return vc
    }
    
    let codeVC = CodeProblemViewController()
    
    let testViewController = TestViewController()
    let mainVC = ViewController()
    
    lazy var items: [SideMenuItem] = [SideMenuItem(icon: UIImage(named: "problem"),
                                              name: "문제",
                                              viewController: .push(codeVC)),
                                 SideMenuItem(icon: UIImage(named: "submit"),
                                              name: "제출근황",
                                              viewController: .modal(codeVC)),
                                 SideMenuItem(icon: UIImage(named: "my"),
                                              name: "마이 페이지",
                                              viewController: .embed(codeVC)),
                                 SideMenuItem(icon: UIImage(named: "home"),
                                              name: "메인 페이지",
                                              viewController: .embed(mainVC)),
                                 SideMenuItem(icon: nil, name: "추천", viewController: .push(testViewController))]
    
    lazy var sideMenuViewController = SideMenuViewController(sideMenuItems: items)
    lazy var containerViewController = ContainerViewController(sideMenuViewController: sideMenuViewController,rootViewController: mainVC)
    
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
        appleLoginManager?.settingLoginView()
        
        
        loginView.moveTomain = { [weak self] in
            guard let self else {return}
            self.navigationController?.pushViewController(containerViewController, animated: true)
        }
        
        
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



