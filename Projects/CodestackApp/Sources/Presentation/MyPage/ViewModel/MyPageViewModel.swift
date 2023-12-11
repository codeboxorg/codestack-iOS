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

class MyPageViewModel: ViewModelType,Stepper{
    
    struct Input{
        var editProfileEvent: Signal<Void>
        var profileImageValue: Signal<Data>
        var viewDidLoad: Signal<Void>
//        var viewWillDisapear: Signal<Void>
//        var imageLoading: Driver<ProfileView.LoadingState>
    }
    
    struct Output{
        var userProfile: Driver<User>
        var loading: Driver<ProfileView.LoadingState>
    }
    
    struct Dependency {
        let authService: AuthServiceType
        let apolloService: WebRepository
    }
    
    var steps = PublishRelay<Step>()
    private var disposeBag = DisposeBag()
    
    private let authService: AuthServiceType
    let apolloService: WebRepository
    
    init(dependency: Dependency) {
        self.authService = dependency.authService
        self.apolloService = dependency.apolloService
    }
    
    private let userProfile = BehaviorRelay<User>(value: UserManager.shared.profile)

    func transform(input: Input) -> Output {
        
        input
            .editProfileEvent
            .map{ _ in CodestackStep.profileEdit}
            .emit(to: steps)
            .disposed(by: disposeBag)
        
        let loading = profileImage(update: input.profileImageValue)
        let activated = loading.distinctUntilChanged()
        
        input.viewDidLoad
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .withUnretained(self)
            .flatMap{ vm, _ in vm.apolloService.getMe(query: Query.getMe()).asObservable() }
            .subscribe(with: self, onNext: { vm, user in
                vm.userProfile.accept(user)
                loading.onNext(.loaded(user.profileImage))
            },onError: { vm, err in
                loading.onNext(.loaded(nil))
            }).disposed(by: disposeBag)
            
        return Output(userProfile: userProfile.asDriver(),
                      loading: activated.asDriver(onErrorJustReturn: .notLoading))
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
    
    private func profileImage(update profileImageValue: Signal<Data>) -> BehaviorSubject<ProfileView.LoadingState> {
        
        let loading = BehaviorSubject<ProfileView.LoadingState>(value: .notLoading)
        
        profileImageValue
            .asObservable()
            .do(onNext: { _ in loading.onNext(.loading) })
            .withUnretained(self)
            .flatMap { vm,data in vm.authService.editProfile(data).asObservable() }
            .do(onNext: { image in loading.onNext(.loaded(image))})
            .do(onError: {_ in loading.onNext(.loaded(nil))})
            .subscribe(with: self, onNext: { vm, user in
                Log.debug("success: \(user)")
                //  vm.userProfile.accept(user)
            }).disposed(by: disposeBag)
        
        return loading
    }
}
