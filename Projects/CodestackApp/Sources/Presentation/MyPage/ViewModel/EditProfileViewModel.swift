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
        var editProfileEvent: Signal<EditViewModel>
        var validState: Driver<ValidState>
    }
    
    struct Output {
        var member: BehaviorRelay<EditViewModel>
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
    private var member = BehaviorRelay<EditViewModel>(value: .sample)
    
    func transform(input: Input) -> Output {
        input.validState
            .drive(validState)
            .disposed(by: disposeBag)
        
        // TODO: valid State
        // 상태를 보고 request를 보낼지 말지 판별해야함
        // 알아서 잘 하셈
        // vm.profileUsecase.editFBProfile
        
        input.editProfileEvent
            .asObservable()
            .map { ($0.toDomain(), $0.image) }
            .withUnretained(self)
            .flatMapFirst { vm, vo -> Observable<Result<MemberVO, Error>> in
                let (memberVO, imageData) = vo
                return vm.profileUsecase
                    .updateEmail(member: memberVO)
                    .asObservable()
                
                // MARK: PRofile Update Query
//                return vm.profileUsecase
//                    .editFBProfile(memberVO.nickName,imageData)
//                    .asSignalJust()
            }
            .subscribe(with: self, onNext: { vm, result in
                switch result {
                case .success(let vo):
                    Log.debug("vo: \(vo)")
                case .failure(let error):
                    Log.debug("vo: \(error)")
                }
                vm.steps.accept(CodestackStep.toastMessage("성공하였습니다."))
            }).disposed(by: disposeBag)
        
        return Output(member: member)
    }
}
