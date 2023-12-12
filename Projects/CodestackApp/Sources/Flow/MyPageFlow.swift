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
        let injector: Injectable
    }
    
    private let injector: Injectable
    
    init(dependency: Dependency) {
        self.injector = dependency.injector
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
        let profileVC = injector.resolve(MyPageViewController.self)
        let profileViewModel = injector.resolve(MyPageViewModel.self)
        profileVC.navigationItem.title = "마이페이지"
        self.rootViewController.pushViewController(profileVC, animated: true)
        return .one(flowContributor:
                .contribute(withNextPresentable: profileVC,
                            withNextStepper: CompositeStepper(steppers: [DefaultStepper(), profileViewModel]))
        )
    }
    
    func navigateToEditProfile() -> FlowContributors {
        let vc = ProfileImageViewController.create(with: UIImage(systemName: "heart"))
        vc.modalPresentationStyle = .fullScreen
        self.rootViewController.present(vc, animated: true)
        return .none
    }
}
