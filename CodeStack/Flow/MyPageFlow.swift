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
    
    private var codestackService: CodestackAuthorization
    
    init(codestackService: CodestackAuthorization) {
        self.codestackService = codestackService
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
        default:
            return .none
        }
    }
    
    func navigateToMyPage() -> FlowContributors {
        let viewmodel = MyPageViewModel(service: self.codestackService)
        let profileVC = MyPageViewController.create(with: viewmodel)

        profileVC.navigationItem.title = "마이페이지"
        self.rootViewController.pushViewController(profileVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: profileVC,
                                                 withNextStepper: CompositeStepper(steppers: [DefaultStepper(),
                                                                                              viewmodel])))
    }
    
    func navigateToEditProfile() -> FlowContributors {
        
        return .none
    }
}
