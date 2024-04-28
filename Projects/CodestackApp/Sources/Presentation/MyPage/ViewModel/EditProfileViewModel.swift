//
//  EditProfileViewModel.swift
//  CodestackApp
//
//  Created by 박형환 on 1/15/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa
import Domain
import Global


final class EditProfileViewModel: ViewModelType, Stepper {
    
    struct Input {
        var profileImageSelected: Observable<Data>
        var editProfileEvent: Signal<EditViewModel>
        var validState: Driver<ValidState>
    }
    
    struct Output {
        var member: BehaviorRelay<EditViewModel>
        var editButtonLoading: BehaviorRelay<Bool>
    }
    
    struct ValidState {
        var email: Bool = false
        var nickname: Bool = false
    }
    
    struct Dependency {
        let profileUsecase: ProfileUsecase
        let initState: MemberVO
        let profileImage: Data
    }

    static func create(with dp: Dependency) -> EditProfileViewModel {
        EditProfileViewModel(dependency: dp)
    }
    
    init(dependency: Dependency) {
        self.profileUsecase = dependency.profileUsecase
        member.accept(dependency.initState.toVM(dependency.profileImage))
    }
    
    private let profileUsecase: ProfileUsecase
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    private var disposeBag = DisposeBag()
    
    private var validState = BehaviorRelay<ValidState>(value: .init())
    public var member = BehaviorRelay<EditViewModel>(value: .sample)
    private var editButtonLoading = BehaviorRelay<Bool>(value: false)
    
    private var updateCount: Int = 0
    
    func transform(input: Input) -> Output {
        input.validState
            .drive(validState)
            .disposed(by: disposeBag)
        
        input.editProfileEvent
            .asObservable()
            .withLatestFrom(member) { editMember, member in
                member.isEqual(to: editMember)
            }
            .withUnretained(self)
            .flatMapFirst { vm, states -> Observable<String> in
                vm.updateUserInfo(states)
            }
            .subscribe(with: self, onNext: { vm, result in
                vm.updateCount -= 1
                if vm.updateCount == 0 {
                    vm.editButtonLoading.accept(false)
                    let toastValue = ToastValue(type: .success, title: "변경", message: "프로필 변경에 성공하셨습니다")
                    vm.steps.accept(CodestackStep.toastV2Value(toastValue))
                }
            }, onError: { vm, value in
                vm.editButtonLoading.accept(false)
                let toastValue = ToastValue(type: .error, title: "실패", message: "프로필 변경에 실패하였습니다.")
                vm.steps.accept(CodestackStep.toastV2Value(toastValue))
            }).disposed(by: disposeBag)
        
        return Output(member: member, editButtonLoading: editButtonLoading)
    }
    
    private func updateUserInfo(_ states: [UpdateState]) -> Observable<String> {
        var merge: [Observable<String>] = []
        
        for state in states {
            switch state {
            case .imageState(let data, let nickname):
                merge.append(profileUsecase.update(profileImage: data, nickname: nickname, updateCount: &updateCount))
                
            case .email(let string):
                merge.append(profileUsecase.update(email: string, updateCount: &updateCount))
                
            case .nickname(let string):
                merge.append(profileUsecase.update(nickname: string, updateCount: &updateCount))
            }
        }
        
        if merge.count >= 1 { editButtonLoading.accept(true) }
        else {
            let toastValue = ToastValue(type: .success, title: "성공", message: "프로필 변경에 성공하셨습니다")
            steps.accept(CodestackStep.toastV2Value(toastValue))
        }
        
        return Observable.merge(merge)
    }
}
