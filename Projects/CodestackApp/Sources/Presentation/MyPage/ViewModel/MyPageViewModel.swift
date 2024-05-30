//
//  MyPageViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/16.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa
import Global
import Domain

class MyPageViewModel: ViewModelType, Stepper {
    
    struct Input {
        var editProfileEvent: Signal<Data>
        var viewDidLoad: Signal<Void>
        var codeModelSeleted: Signal<CodestackVO>
        var codeModelDeleted: Observable<Int>
        var myPostSeleted: Signal<StoreVO>
        var navigateToCodeWrite: Observable<Void>
    }
    
    struct Output {
        var userProfile: Driver<MemberVO>
        var loading: Driver<ProfileView.LoadingState>
        var myCodestackList: Driver<[CodestackVO]>
        var myPostingList: Driver<[StoreVO]>
    }
    
    struct Dependency {
        let profileUsecase: ProfileUsecase
        let firebaseUsecase: FirebaseUsecase
        let codeUsecase: CodeUsecase
    }
    
    var steps = PublishRelay<Step>()
    private var disposeBag = DisposeBag()
    
    private let profileUsecase: ProfileUsecase
    private let codeUsecase: CodeUsecase
    private let firebaseUsecase: FirebaseUsecase
    
    init(dependency: Dependency) {
        self.profileUsecase = dependency.profileUsecase
        self.codeUsecase = dependency.codeUsecase
        self.firebaseUsecase = dependency.firebaseUsecase
    }
    
    private let imageCacheClient: ImageCacheClient = ImageCacheClient.shared
    private let myPostingList = BehaviorSubject<[StoreVO]>(value: [])
    
    private lazy var userPorfileImage = profileUsecase.userProfileImage
    private lazy var loading = BehaviorSubject<ProfileView.LoadingState>(value: .notLoading)
    private lazy var activated = loading.distinctUntilChanged()
    private lazy var userProfile = profileUsecase.userProfile
    private lazy var myCodestackList = codeUsecase.myCodestackList

    func transform(input: Input) -> Output {
        userPorfileImage.asObservable()
            .withUnretained(self)
            .do(onNext: { vm, image in vm.imageCacheClient.setMyImageInCache(image) })
            .map { .loaded($1) }
            .bind(to: loading)
            .disposed(by: disposeBag)
        
        input
            .editProfileEvent
            .asObservable()
            .withUnretained(userProfile)
            .flatMap { userProfile, imageData -> Observable<(MemberVO, Data)> in
                let myImageFromCache = Observable.just(imageData)
                let userProfile = userProfile.take(1).asObservable()
                return Observable.zip(userProfile, myImageFromCache)
            }
            .map { value in
                CodestackStep.profileEdit(value.0, value.1)
            }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        
        // TODO: USer get
        input.navigateToCodeWrite
            .map { _ in CodestackStep.codeEditorStep(CodeEditor(codestackVO: .new, select: .default))}
            .bind(to: steps)
            .disposed(by: disposeBag)

        postAction(selected: input.myPostSeleted)
        codeAction(codeModelSeleted: input.codeModelSeleted, codeModelDeleted: input.codeModelDeleted)
        viewDidLoadAction(input.viewDidLoad)
            
        return Output(userProfile: userProfile.asDriver(),
                      loading: activated.asDriver(onErrorJustReturn: .notLoading),
                      myCodestackList: myCodestackList.asDriver(onErrorJustReturn: [.mock]),
                      myPostingList: myPostingList.asDriver(onErrorJustReturn: [.mock,.mock]))
    }
    
    private func postAction(selected: Signal<StoreVO>) {
        selected
            .withUnretained(firebaseUsecase)
            .flatMapLatest { usecase, value -> Signal<(PostVO, StoreVO)> in
                let postMarkDown = usecase
                    .fetchPostByID(value.markdownID)
                    .asSignal(onErrorJustReturn: .init(markdown: ""))
                
                return Signal.zip(postMarkDown, Signal.just(value))
            }
            .map { value in
                let (post, store) = value
                return CodestackStep.richText(post.markdown, store)
            }
            .emit(to: steps)
            .disposed(by: disposeBag)
    }
    
    private func codeAction(codeModelSeleted: Signal<CodestackVO>, codeModelDeleted: Observable<Int>) {
        codeModelDeleted
            .withUnretained(self)
            .flatMapLatest { vm, index in
                vm.codeUsecase.deleteCode(index: index)
            }
            .subscribe(with: self, onNext: { vm, state in
                Log.debug("delete State: \(state)")
            }).disposed(by: disposeBag)
        
        codeModelSeleted
            .map { CodestackStep.codeEditorStep(CodeEditor(codestackVO: $0, select: $0.languageVO)) }
            .emit(to: steps)
            .disposed(by: disposeBag)
    }
    
    
    private func viewDidLoadAction(_ viewDidLoad: Signal<Void>) {
        viewDidLoad
            .withUnretained(self)
            .flatMap { vm, value in
                vm.firebaseUsecase
                    .fetchMePostList()
                    .asSignal(onErrorJustReturn: [])
            }
            .emit(to: myPostingList)
            .disposed(by: disposeBag)
            
        
        viewDidLoad
            .withUnretained(self)
            .flatMap { vm, value in
                vm.codeUsecase.fetchCodeList()
                    .asSignal(onErrorJustReturn: .success([]))
            }
            .compactMap { try? $0.get() }
            .emit(to: myCodestackList)
            .disposed(by: disposeBag)
        
        
        viewDidLoad
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .withUnretained(self)
            .do(onNext: { vm, _ in vm.loading.onNext(.loading) } )
            .flatMap{ vm, _ in vm.profileUsecase.fetchProfile() }
            .subscribe(with: self, onNext: { vm, member in
                let loading = vm.loading
                let profileImage = member.profileImage
                vm.userProfile.accept(member)
                vm.bindingProfileImage(loading, profileImage)
            },onError: { vm, err in
                let data = CodestackAppAsset.codeStack.image.pngData()!
                vm.loading.onNext(.loaded(data))
            }).disposed(by: disposeBag)
    }
    
    struct DetailInput {
        var viewWillDissapear: Signal<Void>
        var backbuttonTap: Signal<Void>
    }
    
    func profileDetailBinding(input: DetailInput) {
        input.viewWillDissapear
            .map { CodestackStep.profileEditDissmiss }
            .emit(to: steps)
            .disposed(by: disposeBag)
        
        input.backbuttonTap
            .map { CodestackStep.profileEditDissmiss }
            .emit(to: steps)
            .disposed(by: disposeBag)
    }
    
    private func bindingProfileImage(_ loading: BehaviorSubject<ProfileView.LoadingState>,
                                     _ profileImageString: String) 
    {
        if let myProfileImage = imageCacheClient.getMyImageFromCache() {
            loading.onNext(.loaded(myProfileImage.pngData()!))
        } else {
            if let url = URL(string: profileImageString),
               let data = try? Data(contentsOf: url) {
                loading.onNext(.loaded(data))
                imageCacheClient.setMyImageInCache(data)
            } else {
                let data = CodestackAppAsset.codeStack.image.pngData()!
                loading.onNext(.loaded(data))
                imageCacheClient.setMyImageInCache(data)
            }
        }
    }
}
