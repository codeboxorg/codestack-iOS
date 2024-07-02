//
//  ActionProvider.swift
//  CodestackApp
//
//  Created by 박형환 on 5/30/24.
//  Copyright © 2024 com.hwan. All rights reserved.
//

import RxSwift
import UIKit
import Domain
import RxGesture
import RxCocoa
import SafariServices

// MARK:    "  _ " -> ViewModel 에 전달되는 Action Trigger
// MARK:    " v_ " -> View 자체 Action
// MARK:    " _$ " -> View, ViewModel Action 전달

final class ActionProvider: _ActionProvider<CodeEditorViewController> {
    
    @DynamicPublishWrapper var linkDector: URL
    @DynamicBehaviorWrapper var dynamicLanguage: LanguageVO = .default
    private(set) var languageSubject = BehaviorSubject<LanguageVO>(value: .default)
    
    private(set) var languages: [LanguageVO] = []
    private var disposeBag = DisposeBag()
    
    private unowned var popUpView: ProblemPopUpView {
        viewController.problemPopUpView
    }
    
    private var dynamicWrapped: DynamicWrapperView<ProblemPopUpView> {
        viewController._problemPopUpView
    }
    
    private(set) lazy var _backButtonTap: Driver<Void>
    = dynamicWrapped.backButton.tap.asDriver()
    
    private(set) lazy var _submissionID: Driver<SubmissionID>
    =
    Observable
        .just(viewController.editorType.getSubmissionID())
        .asDriverJust()
    
    private(set) lazy var _languageDriver: Driver<LanguageVO>
    =
    languageSubject
        .asDriver(onErrorJustReturn: .default)
    
    private(set) lazy var _submissionListGesture: Driver<Void>
    =
    popUpView
        .submissionListStepButton
        .container.rx.gesture(.tap())
        .when(.recognized)
        .map {_ in () }
        .asDriver(onErrorJustReturn: ())
    
    private(set) lazy var _$favoriteTap: Driver<Bool>
    =
    popUpView
        .heartButton.rx.tap
        .compactMap { [weak self] in
            guard let self else { return false }
            return !self.viewController.problemPopUpView.heartButton.flag
        }
        .asDriver(onErrorJustReturn: false)
    
    
    private(set) lazy var _dissmissTap: Driver<Void>
    =
    popUpView
        .backButton.rx.tap
        .asDriver()
    
    private(set) lazy var _editorTitleFieldChange: Driver<String>
    =
    popUpView
        .editorTitleField.rx.text
        .orEmpty
        .asDriver()
    
    private(set) lazy var _$refreshTap: Driver<Void>
    =
    popUpView
        .refreshButton.rx.tap
        .asDriver()
    
    private lazy var v_problemStepButtonGesture: Observable<SolveResultType>
    =
    popUpView
        .problemStepButton
        .container.rx.gesture(.tap())
        .when(.recognized)
        .map { _ in SolveResultType.problem }
    
    private lazy var v_resultStepButtonGesture: Observable<SolveResultType>
    =
    popUpView
        .resultStepButton
        .container.rx.gesture(.tap())
        .when(.recognized)
        .map { _ in SolveResultType.result(nil) }
    
    private lazy var v_submissionListGesture: Observable<SolveResultType>
    =
    popUpView
        .submissionListStepButton
        .container.rx.gesture(.tap())
        .when(.recognized)
        .map { _ in SolveResultType.resultList([]) }
    
    
    private lazy var _$sendButtonAction: Driver<Void>
    =
    popUpView
        .sendButton.rx.tap
        .asDriver()
    
    /// editorType.problemID
    func sendSubmissionAction(_ id: ProblemID) -> Driver<String> {
        _$sendButtonAction
            .map { _ in "\(id)" }
            .startWith("\(id)")
    }
    
    
    private(set) lazy var _inputTextChangeAction: Driver<String>
    =
    viewController
        .ediotrContainer
        .codeUITextView.rx.text
        .debounce( .milliseconds(300), scheduler: MainScheduler.instance)
        .compactMap { $0 }
        .asDriverJust()
    
    override func actionBinding() {
        Observable.merge(
            v_resultStepButtonGesture,
            v_problemStepButtonGesture,
            v_submissionListGesture
        )
        .do(onNext: { [weak self] _ in self?.viewController.problemPopUpView.impact() })
        .bind(to: viewController.binderProvider.problemPopUpViewPageBinder)
        .disposed(by: disposeBag)
        
        _$refreshTap
            .drive(
                with: self,
                onNext: { provider, _ in
                    provider.viewController.problemPopUpView.refreshButton.isHidden = true
                    provider.viewController.problemPopUpView.refreshLabel.text = "로딩중......"
                    provider.viewController.problemPopUpView.activityIndicator.startAnimating()
                }
            )
            .disposed(by: disposeBag)
        
        _$favoriteTap
            .drive(
                with: self,
                onNext: { provider, _ in
                    provider.viewController
                        .problemPopUpView
                        .heartButton.flag.toggle()
                }
            )
            .disposed(by: disposeBag)
        
        $linkDector
            .subscribe(
                with: self,
                onNext: { provider, url in
                    let sf = SFSafariViewController(url: url)
                    sf.delegate = provider.viewController
                    provider.viewController
                        .navigationController?
                        .pushViewController(sf, animated: false)
                }
            )
            .disposed(by: disposeBag)
        
//        v_linkDetector
//            .subscribe(
//                with: self,
//                onNext: { provider, url in
//                    let sf = SFSafariViewController(url: url)
//                    sf.delegate = provider.viewController
//                    provider.viewController
//                        .navigationController?
//                        .pushViewController(sf, animated: false)
//                }
//            )
//            .disposed(by: disposeBag)
        
        _$sendButtonAction
            .skip(1)
            .drive(
                with: self,
                onNext: { provider, _ in
                    let controller = provider.viewController
                    let flag = controller.editorType.isProblemSolve()
                    if flag {
                        controller
                            .binderProvider
                            .problemPopUpViewPageBinder
                            .onNext(.result(nil))
                    }
                }
            )
            .disposed(by: disposeBag)
    }
}

extension ActionProvider {
    
    var languageButton: UIButton {
        viewController
            .problemPopUpView
            .languageButton
    }
    
    /// 언어 Title Action && languageRelay에 값 전달 -> ViewModel로 데이터 전달
    private var setTitleAction: (UIAction) -> () {
        { [weak self] action in
            guard let self else {return}
            if let value = self.languages.filter({ $0.name == action.title }).first {
                self.languageButton.rx.title.onNext(value.name)
                // self.languageSubject.onNext(value)
                self.dynamicLanguage = value
            }
        }
    }
    
    /// 언어 설정 하기 위한 함수
    /// - Parameter languages: 언어 배열
    func setLangueMenu(languages: [LanguageVO]){
        self.languages = languages

        let element = languages.map { lan in
            UIAction(title: lan.name, handler: setTitleAction)
        }

        if let lan = languages.first {
            self.languageButton.setTitle(lan.name, for: .normal)
        }

        languageButton.showsMenuAsPrimaryAction = true
        languageButton.menu = UIMenu(title: "언어", image: nil, identifier: nil, options: .destructive, children: element)
    }
}
