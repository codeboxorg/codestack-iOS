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
        var editProfileImage: Signal<ProfileImage>
    }
    
    struct Output{
        var userProfile: Driver<ProfileView.Profile>
    }
    
    var steps = PublishRelay<Step>()
    private var disposeBag = DisposeBag()
    private let service: CodestackAuthorization
    
    init(service: CodestackAuthorization) {
        self.service = service
    }
    
    
    private var userProfile = BehaviorRelay<ProfileView.Profile>(value: .init(imageURL: nil,
                                                                              name: "",
                                                                              rank: ""))

    func transform(input: Input) -> Output {
        
        input
            .editProfileEvent
            .map{ _ in CodestackStep.profileEdit}
            .emit(to: steps)
            .disposed(by: disposeBag)
        
        return Output(userProfile: userProfile.asDriver())
    }
    
    
    func request(image: ProfileImage) {
        guard let pngImage = image.pngData() else { return }
        _ = service.editProfile(image: pngImage)
            .subscribe(with: self, onSuccess: { vm, value in
                Log.debug("success OR Fail edit image :\(value)")
            })
    }
    
}
