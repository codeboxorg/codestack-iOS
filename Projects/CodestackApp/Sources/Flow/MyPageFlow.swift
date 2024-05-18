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
import Global
import Domain

class MyPageFlow: Flow {
    
    var root: Presentable {
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
        viewController.view.backgroundColor = UIColor.systemBackground
        viewController.setNavigationBarHidden(false, animated: true)
        return viewController
    }()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        
        switch codestackStep {
        
        case .profilePage:
            return navigateToMyPage()
        
        case .profileEdit(let memberVO, let profile):
            return navigateToDetailProfile(memberVO, profile)
        
        case .profileEditDissmiss:
            self.rootViewController.dismiss(animated: true)
        
        case .richText(let markdown, let storeVO):
            let vc = injector.resolve(RichTextViewController.self,
                                      markdown,
                                      storeVO,
                                      RichViewModel.ViewType.myPosting)
            rootViewController.pushViewController(vc, animated: true)
            
        case .toastV2Value(let toastValue):
            return toast(toastValue)
        
        case .codeEditorStep(let editor):
            return navigateCodeEditorVC(editor)
            
        case .problemComplete:
            self.rootViewController.setNavigationBarHidden(false, animated: true)
            self.rootViewController.popViewController(animated: true)
            
        default: return .none
        }
        return .none
    }
    
    func navigateToDetailProfile(_ memberVO: MemberVO, _ profile: Data) -> FlowContributors {
        let editProfileVC = injector.resolve(EditProfileViewController.self, memberVO, profile)
        editProfileVC.modalPresentationStyle = .automatic
        editProfileVC.sheetPresentationController?.detents = [.medium(), .large()]
        rootViewController.present(editProfileVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: editProfileVC,
                                                 withNextStepper: editProfileVC.editViewModel))
    }
    
    private func navigateCodeEditorVC(_ editor: EditorTypeProtocol) -> FlowContributors {
        let editorVC = injector.resolve(CodeEditorViewController.self, editor)
        let stepper = injector.resolve(CodeEditorStepper.self)
        editorVC.hidesBottomBarWhenPushed = true
        
        self.rootViewController.pushViewController(editorVC, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: editorVC, withNextStepper: stepper))
    }
    
    func navigateToMyPage() -> FlowContributors {
        let profileVC = injector.resolve(MyPageViewController.self)
        profileVC.navigationItem.title = "마이페이지"
        self.rootViewController.pushViewController(profileVC, animated: true)
        return .one(flowContributor:
                .contribute(withNextPresentable: profileVC,
                            withNextStepper: CompositeStepper(steppers: [DefaultStepper(),
                                                                         profileVC.myPageViewModel!]))
        )
    }
    
    func navigateToEditProfile() -> FlowContributors {
        let vc = ProfileImageViewController.create(with: UIImage(systemName: "heart"))
        vc.modalPresentationStyle = .fullScreen
        self.rootViewController.present(vc, animated: true)
        return .none
    }
    
    func toast(_ toastValue: ToastValue) -> FlowContributors {
        rootViewController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            let container = self.rootViewController.presentedViewController?.view
            Toast.toastMessage(toastValue, pos: .bottom, container: container)   
        }
        return .none
    }
}
