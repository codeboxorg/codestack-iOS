//
//  ProfileUsecase.swift
//  Domain
//
//  Created by 박형환 on 12/15/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public typealias ImageURL = String

public enum PRConstants {
    case fail
    public var value: String {
        switch self {
        case .fail:
            return "fail"
        }
    }
}

public enum UpdateState {
    case nickname
    case email
    case profileImage
}

public final class ProfileUsecase {

    public let userProfile = BehaviorRelay<MemberVO>(value: MemberVO.sample)
    public let userProfileImage = PublishSubject<Data>()
    
    private var disposeBag = DisposeBag()
    
    private let webRepository: WebRepository
    private let fbRepository: FBRepository
    private let authRepository: AuthRepository
    
    public struct Dependency {
        let webRepository: WebRepository
        let fbRepository: FBRepository
        let authRepository: AuthRepository
        public init(webRepository: WebRepository,
                    fbRepository: FBRepository,
                    authRepository: AuthRepository) {
            self.webRepository = webRepository
            self.fbRepository = fbRepository
            self.authRepository = authRepository
        }
    }
    
    public init(dependency: Dependency) {
        self.webRepository = dependency.webRepository
        self.fbRepository = dependency.fbRepository
        self.authRepository = dependency.authRepository
    }

    public func fetchME() -> Observable<MemberVO> {
        webRepository.getMe().asObservable()
    }
    
    public func editProfile(data: Data) -> Observable<String> {
        webRepository.editProfile(data).asObservable()
            .catchAndReturn(PRConstants.fail.value)
    }
    
    public func fetchProfile() -> Observable<MemberVO> {
        Observable.just(webRepository.getMemberVO())
            .do(onNext: { [weak self] value in
                self?.userProfile.accept(value)
            })
    }
    
    public func fetchProfileImage() -> Observable<Data> {
        fbRepository.fetchMyProfileImage()
    }
    
    public func update(email: String, updateCount: inout Int) -> Observable<String> {
        updateCount += 1
        return fbRepository.update(email: email).asObservable()
            .withUnretained(self)
            .do(onNext: { usecase, _ in
                usecase.webRepository.updateEmail(email)
                usecase.binding(email: email)
            })
            .map { $1 }
    }
    
    public func update(nickname: String, updateCount: inout Int) -> Observable<String> {
        updateCount += 1
        return fbRepository.update(nickname: nickname)
            .andThen(Observable.just("success"))
            .withUnretained(self)
            .do(onNext: { usecase, _ in
                usecase.webRepository.updateMember(nickname)
                usecase.binding(nickname: nickname)
            })
            .map { $1 }
    }
    
    public func update(profileImage: Data, nickname: String, updateCount: inout Int) -> Observable<String> {
        updateCount += 1
        return fbRepository.update(profileImage: profileImage, nickname: nickname)
            .withUnretained(self)
            .do(onNext: { usecase, urlString in
                usecase.binding(image: urlString)
                usecase.userProfileImage.onNext(profileImage)
            })
            .map { $1 }
    }
}

extension ProfileUsecase {
    private func binding(nickname: String) {
        Observable.just(nickname)
            .withLatestFrom(userProfile) { nickname, profile in
                var profile = profile
                profile.nickName = nickname
                return profile
            }
            .bind(to: userProfile)
            .disposed(by: disposeBag)
    }
    
    private func binding(email: String) {
        Observable.just(email)
            .withLatestFrom(userProfile) { email, profile in
                var profile = profile
                profile.email = email
                return profile
            }
            .bind(to: userProfile)
            .disposed(by: disposeBag)
    }
    
    private func binding(image: String) {
        Observable.just(image)
            .withLatestFrom(userProfile) { image, profile in
                var profile = profile
                profile.profileImage = image
                return profile
            }
            .bind(to: userProfile)
            .disposed(by: disposeBag)
    }
}


