//
//  WritePostingViewModel.swift
//  CodestackApp
//
//  Created by 박형환 on 3/5/24.
//  Copyright © 2024 hyeong. All rights reserved.
//


import RxSwift
import RxFlow
import Domain
import RxRelay


struct StoreViewModel {
    var storeVO: StoreVO
    var content: String
    
    static var `default`: Self = .init(storeVO: .default, content: "")
    
    init(storeVO: StoreVO, content: String) {
        self.storeVO = storeVO
        self.content = content
    }
}

final class WritePostingViewModel: ViewModelType, Stepper {
    
    var steps = PublishRelay<Step>()
    
    struct Input {
        var initState: Observable<StoreVO>
        var saveAction: Observable<[String]>
    }
    
    typealias MarkDown = String
    
    struct Output {
        var postingState: Observable<StoreViewModel>
        var loading: Observable<Bool>
        // var showPreviewState: Observable<StoreViewModel>
    }
    
    struct Dependency {
        let profileUsecase: ProfileUsecase
        let firebaseUsecase: FirebaseUsecase
    }
    
    private let profileUsecase: ProfileUsecase
    private let firebaseUsecase: FirebaseUsecase
    
    private var disposeBag = DisposeBag()
    private let loadingState = PublishSubject<Bool>()
    private var showPreviewState = BehaviorSubject<StoreViewModel>(value: .default)
    private let postingState = BehaviorSubject<StoreViewModel>(value: .default)
    
    /// contentInput from SwiftEditor
    public var contentInput = BehaviorSubject<String>(value: "")
    public var titleInput = BehaviorSubject<String>(value: "제목을 입력해주세요")
    public var introduceInput = BehaviorSubject<String>(value: "글에 대한 설명을 입력해주세요")
    
    init(dependency: Dependency) {
        self.profileUsecase = dependency.profileUsecase
        self.firebaseUsecase = dependency.firebaseUsecase
    }
    
    /// Profile Usecase 로부터 Profile 정보 가져오는 함수
    /// - Returns: Observable
    func getMeInfo() -> Observable<(StoreViewModel,MemberVO)> {
        Observable.zip(postingState.take(1), profileUsecase.userProfile.take(1))
    }
    
    func transform(input: Input) -> Output {
        contentInput(initState: input.initState)
        saveAction(save: input.saveAction)
    
        return Output(postingState: postingState.asObservable(),
                      loading: loadingState.asObservable())
    }
    // 강성준
    
    private func contentInput(initState: Observable<StoreVO>) {
        Observable.combineLatest(contentInput.asObservable(), initState)
            .map { content, inputState in StoreViewModel(storeVO: inputState, content: content) }
            .subscribe(with: self, onNext: { vm , value in
                vm.postingState.onNext(value)
            })
            .disposed(by: disposeBag)
        
        contentInput.asObservable()
            .subscribe(with: self, onNext: { vc, value in
                
            }).disposed(by: disposeBag)
    }
    
    private func saveAction(save input: Observable<[String]>) {
        // MARK: Save Content Action Flag
        input
            .withUnretained(self)
            .do(onNext: { vm, _ in vm.loadingState.onNext(true)} )
            .flatMap { vm, tags in
                Observable.zip(
                    vm.getMeInfo(),
                    Observable.just(tags)
                )
            }
            .map { (nested: ((StoreViewModel, MemberVO), [String])) in
                var ((viewModel, member), tags) = nested
                let storeVO = viewModel.storeVO.makeViewModel(
                    nickname: member.nickName,
                    imageURL: member.profileImage,
                    tags: tags
                )
                let html = try viewModel.content.toHTML()
                return CodestackStep.richText(html, storeVO)
            }
        //            .flatMapLatest { vm, state in
        //                let (author, markDownContent) = state
        //                return vm.firebaseUsecase.writeContent(author, markDownContent)
        //            }
            .subscribe(with: self, onNext: { vm, value in
                let step: CodestackStep = value
                vm.steps.accept(step)
                vm.loadingState.onNext(false)
            },onError: { vm, error in
                vm.loadingState.onNext(false)
            }).disposed(by: disposeBag)
    }
}
