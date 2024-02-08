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

class MyPageViewModel: ViewModelType, Stepper{
    
    struct Input {
        var editProfileEvent: Signal<Void>
        var profileImageValue: Driver<Data>
        var viewDidLoad: Signal<Void>
    }
    
    struct Output {
        var userProfile: Driver<MemberVO>
        var loading: Driver<ProfileView.LoadingState>
    }
    
    struct Dependency {
        let profileUsecase: ProfileUsecase
    }
    
    var steps = PublishRelay<Step>()
    private var disposeBag = DisposeBag()
    
    private let profileUsecase: ProfileUsecase
    
    init(dependency: Dependency) {
        self.profileUsecase = dependency.profileUsecase
    }
    
    private let userProfile = BehaviorRelay<MemberVO>(value: MemberVO.sample)
    private let profileImageCahche = BehaviorRelay<Data>(value: Data())

    func transform(input: Input) -> Output {
        let loading = profileImage(update: input.profileImageValue)
        let activated = loading.distinctUntilChanged()
        
        input
            .editProfileEvent
            .asObservable()
            .flatMap { [weak self] _ -> Observable<(Data, MemberVO)> in
                guard let self else { return .just((Data(), .sample))}
                return Observable.zip(self.profileImageCahche.asObservable(),
                                      self.userProfile.take(1).asObservable())
            }
            .map { CodestackStep.profileEdit($0.1, $0.0) }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.viewDidLoad
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .withUnretained(self)
            .flatMap{ vm, _ in vm.profileUsecase.fetchProfile() }
            .subscribe(with: self, onNext: { vm, member in
                vm.userProfile.accept(member)
                if let url = URL(string: member.profileImage),
                   let data = try? Data(contentsOf: url) {
                    loading.onNext(.loaded(data))
                    vm.profileImageCahche.accept(data)
                } else {
                    let data = CodestackAppAsset.codeStack.image.pngData()!
                    loading.onNext(.loaded(data))
                    vm.profileImageCahche.accept(data)
                }
            },onError: { vm, err in
                let data = CodestackAppAsset.codeStack.image.pngData()!
                vm.profileImageCahche.accept(data)
                loading.onNext(.loaded(data))
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
    
    private func profileImage(update profileImageValue: Driver<Data>) -> BehaviorSubject<ProfileView.LoadingState> {
        
        let loading = BehaviorSubject<ProfileView.LoadingState>(value: .notLoading)
        
        profileImageValue
            .asObservable()
            .do(onNext: { _ in loading.onNext(.loading) })
            .withUnretained(self)
            .flatMap { vm,data in
                // TODO: Cache 처리 해야함
                Observable.zip(vm.profileImageCahche.take(1).asObservable(),
                               vm.profileUsecase.editProfile(data: data))
            }
            .subscribe(with: self, onNext: { vm, tuple in
                let (before, newImageURL) = tuple
                if newImageURL == PRConstants.fail.value {
                    // MARK: 실패시 이전 이미지로 교체
                    loading.onNext(.loaded(before))
                }
            }).disposed(by: disposeBag)
        
        return loading
    }
}
