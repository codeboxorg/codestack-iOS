//
//  MyPageFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/13.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import PhotosUI
import Photos

class MyPageFlow: Flow{
    
    var root: Presentable{
        rootViewController
    }
    
    struct Dependency {
        let apolloService: WebRepository
        let authService: AuthServiceType
    }
    
    private let authService: AuthServiceType
    private let apolloService: WebRepository
    
    private lazy var myPageViewModel = MyPageViewModel(dependency: .init(authService: self.authService,
                                                                         apolloService: self.apolloService))
    
    init(dependency: Dependency) {
        self.authService = dependency.authService
        self.apolloService = dependency.apolloService
    }
    
    private let rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(false, animated: true)
        return viewController
    }()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        switch codestackStep{
        case .profilePage:
            return navigateToMyPage()
//        case .profileEdit:
//            Log.debug("profileEdit")
//            return navigateToDetailProfile()
//        case .profileEditDissmiss:
//            self.rootViewController.dismiss(animated: true)
//            return .none
        default:
            return .none
        }
    }
    
    func navigateToMyPage() -> FlowContributors {
        let profileVC = MyPageViewController.create(with: myPageViewModel)
        profileVC.navigationItem.title = "마이페이지"
        self.rootViewController.pushViewController(profileVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: profileVC,
                                                 withNextStepper: CompositeStepper(steppers: [DefaultStepper(),
                                                                                              myPageViewModel])))
    }
    
    func navigateToEditProfile() -> FlowContributors {
        let vc = ProfileImageViewController.create(with: UIImage(systemName: "heart"))
        vc.modalPresentationStyle = .fullScreen
        self.rootViewController.present(vc, animated: true)
        return .none
    }
}
