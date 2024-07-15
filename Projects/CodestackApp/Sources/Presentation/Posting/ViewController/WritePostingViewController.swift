//
//  WritePostingViewController.swift
//  CodestackApp
//
//  Created by 박형환 on 3/4/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxFlow
import Domain
import CommonUI
import Global
import SwiftHangeul
import SwiftDown


final class WritePostingViewController: BaseViewController {
        
    static func create(with viewmodel: WritePostingViewModel) -> WritePostingViewController {
        let vc = WritePostingViewController()
        vc.viewModel = viewmodel
        return vc
    }
    
    private var disposeBag = DisposeBag()
    private(set) var viewModel: WritePostingViewModel!
    lazy var editorViewModel = SwiftDownEditor.ViewModel.init(viewModel)
    
    private var topNavigation = TopNavigationView()
    private lazy var postingView = WritePostingView.create(with: editorViewModel)
    
    private var hanguelFactory = SwiftHangeul()
    
    override func addAutoLayout() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(topNavigation)
        self.view.addSubview(postingView)
        
        topNavigation.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100).priority(.low)
        }
        
        postingView.snp.makeConstraints { make in
            make.top.equalTo(topNavigation.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc func dismissVC(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    deinit { Log.debug("WritePostingViewController Deinit") }
    
    override func applyAttributes() {
        
    }
    
    override func binding() {
        viewModelBinding()
        viewBinding()
    }
}

extension WritePostingViewController {
    var postSelected: Binder<Void> {
        Binder<Void>(self) { target, _ in
            let vc = TagSeletedViewController.create(with: target.viewModel)
            target.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    var postBinder: Binder<StoreViewModel> {
        Binder<StoreViewModel>(self) { target, value in
            
        }
    }
    
    var loadingBinder: Binder<Bool> {
        Binder<Bool>(self) { target, value in
            if value {
                target.topNavigation.sendButton.showLoading()
            } else {
                target.topNavigation.sendButton.hideLoading()
            }
        }
    }
    
    func viewModelBinding() {
        let saveAction 
        = topNavigation.sendButton.rx.tap
            .map { [weak self] _ in
                self?.postingView
                    .tagSelectedView
                    .tags?
                    .sorted() ?? []
            }
            .asObservable()
        let titleObservable = postingView.titleTextField.rx.text.orEmpty.asObservable().defaultThrottle()
        let descriptionObservable = Observable.just("")
        let tagsObservable = Observable.just(["구현"]).asObservable().defaultThrottle()
        
        let combineLatestForm
        = Observable.combineLatest(titleObservable,descriptionObservable,tagsObservable)
            .map { title, descriptions, tags in
                StoreVO.makeViewModel(title,descriptions, tags)
            }
        
        let output = viewModel.transform(
            input: .init(
                initState: combineLatestForm,
                saveAction: saveAction
            )
        )
        
        output.loading
            .bind(to: loadingBinder)
            .disposed(by: disposeBag)
        
        output.postingState
            .take(1)
            .bind(to: postBinder)
            .disposed(by: disposeBag)
    }
    
    func viewBinding() {
        
        topNavigation.dismissButton.rx.tap
            .subscribe(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        KeyBoardManager.shared.keyBoardAppear
            .subscribe(with: self, onNext: { vc, keyboardFrame in
                vc.postingView.keyboardAppear(keyboardFrame.height)
            }).disposed(by: disposeBag)

        KeyBoardManager.shared.keyBoardDissapear
            .subscribe(with: self, onNext: { vc, _ in
                vc.postingView.keyboardDissapear()
            }).disposed(by: disposeBag)
    }
}

extension WritePostingViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let userInterfaceStyle = previousTraitCollection?.userInterfaceStyle else {
            return
        }
        switch userInterfaceStyle {
        case .light:
            editorViewModel.userInterfaceMode = .dark
        case .dark:
            editorViewModel.userInterfaceMode = .light
        default:
            editorViewModel.userInterfaceMode = .light
        }
    }
}


public extension Observable {
    func defaultThrottle() -> Observable<Element> {
        self.throttle(.milliseconds(400), latest: true, scheduler: MainScheduler.instance)
    }
}
