//
//  RegisterViewModel.swift
//  CodestackApp
//
//  Created by 박형환 on 1/19/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxFlow
import Global
import Domain


final class RegisterViewModel: ViewModelType, Stepper {
    
    struct Input {
        let emailSubject: Observable<Bool>
        let nextTriger: Observable<RegisterQuery>
    }
    
    struct PasswordInput {
        let passwordSubject: Observable<Bool>
        let isCorrectPasswordSubject: Observable<Bool>
        let nextTriger: Observable<RegisterQuery>
    }
    
    struct PasswordOutput {
        let passwordReslut: BehaviorSubject<Bool>
        let corretReslut: BehaviorSubject<Bool>
    }
    
    struct AdditionalInput {
        let nickNameSubject: Observable<Bool>
        let registerEvent: Observable<RegisterQuery>
    }
    
    struct Output {
        let isLoading: Observable<Bool>
        let authResult: Observable<AuthResult>
    }
    
    struct AuthResult {
        let sucess: Bool
        let content: String
    }
    
    struct Dependency {
        let step1: RegisterStep1
        let step2: RegisterStep2
        let authUsecase: AuthUsecase
    }
    
    private var authUsecase: AuthUsecase
    var steps = PublishRelay<Step>()
    let step1: RegisterStep1
    let step2: RegisterStep2
    
    private var disposeBag = DisposeBag()
    private let registerQuery = BehaviorSubject<RegisterQuery>(value: .mock)
    private let idSubject = BehaviorSubject<Bool>(value: false)
    private let passwordSubject = BehaviorSubject<Bool>(value: false)
    private let isCorrectPasswordSubject = BehaviorSubject<Bool>(value: false)
    private let emailSubject = BehaviorSubject<Bool>(value: false)
    private let nickNameSubject = BehaviorSubject<Bool>(value: false)
    
    
    init(dependency: Dependency) {
        self.authUsecase = dependency.authUsecase
        self.step1 = dependency.step1
        self.step2 = dependency.step2
    }
    
    func transform(input: Input) -> Output {
        Output(isLoading: .empty(),authResult: .empty())
    }
    
    func emailBinding(input: Input) {
        
        input.emailSubject
            .bind(to: emailSubject)
            .disposed(by: disposeBag)
        
        input.nextTriger
            .withUnretained(self)
            .withLatestFrom(emailSubject.asObservable()) { value, flag -> RegisterQuery in
                let vm = value.0
                let query = value.1
                let emailValid = flag
                if vm.isValid(email: emailValid) {
                    return query
                } else {
                    return .mock
                }
            }
            .filter { !$0.email.isEmpty }
            .withUnretained(self)
            .do(onNext: { vm, query in
                vm.registerQuery.onNext(query)
            })
            .map { vm, _ in CodestackStep.password}
            .bind(to: steps)
            .disposed(by: disposeBag)
    }
    
    func passwordBinding(input: PasswordInput) {
        input.passwordSubject
            .bind(to: passwordSubject)
            .disposed(by: disposeBag)
        
        input.isCorrectPasswordSubject
            .bind(to: isCorrectPasswordSubject)
            .disposed(by: disposeBag)
        
        let combineLatest = Observable.combineLatest(passwordSubject.asObservable(),
                                                     isCorrectPasswordSubject.asObservable())
        
        input.nextTriger
            .withUnretained(self)
            .withLatestFrom(combineLatest) { value, flag -> RegisterQuery in
                let vc = value.0
                let query = value.1
                let (pwd, correctPwd) = flag
                if vc.isValid(pwd, correctPwd) {
                    return query
                } else {
                    return .mock
                }
            }
            .filter { !$0.password.isEmpty }
            .withLatestFrom(registerQuery) { pwd, email in
                var query = email
                query.password = pwd.password
                return query
            }
            .withUnretained(self)
            .do(onNext: { vm, query in
                vm.registerQuery.onNext(query)
            })
            .map { vm, _ in CodestackStep.additionalInfo }
            .bind(to: step1.steps)
            .disposed(by: disposeBag)
    }
    
    func registerEvent(input: AdditionalInput) -> Output {
        
        input.nickNameSubject
            .bind(to: nickNameSubject)
            .disposed(by: disposeBag)
        
        let combineLatest = Observable.combineLatest(Observable.just(true),
                                                     nickNameSubject.asObservable())
        let isLoading = BehaviorSubject<Bool>(value: false)
        let authResult = PublishSubject<AuthResult>()
        
        input.registerEvent
            .do(onNext: { _ in isLoading.onNext(true)} )
            .withUnretained(self)
            .withLatestFrom(combineLatest) { value, flag -> RegisterQuery in
                let vc = value.0
                let query = value.1
                let (_ , nickname) = flag
                if vc.isValid(nickname) {
                    return query
                } else {
                    isLoading.onNext(false)
                    return .mock
                }
            }
            .filter { !$0.nickname.isEmpty }
            .withLatestFrom(registerQuery) { nickname, idpwd in
                var query = idpwd
                query.nickname = nickname.nickname
                return query
            }
            .withUnretained(self)
            .flatMap { vc, query -> Observable<State<MemberVO>> in
                // MARK: Firebase Auth
                vc.authUsecase.firebaseRegister(query)
                    .map { value in .success(value) }
                    .catch { err in .just(.failure(err))}
                
                // MARK: Codestack Auth
                // guard let authUsecase else { return .just(false) }
                // return authUsecase.signUpRequest(query: query)
            }
            .subscribe(with: self, onNext: { vc, result in
                isLoading.onNext(false)
                switch result {
                case .success(let memberVO):
                    let authRes = vc.interactor()
                    vc.step2toast(type: .success, content: authRes.content)
                    authResult.onNext(authRes)
                    vc.step2.steps.accept(CodestackStep.registerDissmiss(memberVO))
                    
                case .failure(let err):
                    let authRes = vc.errorInteractor(err)
                    vc.step2toast(type: .error, content: "\(authRes.content)")
                    authResult.onNext(authRes)
                }
            }).disposed(by: disposeBag)
        
        
        return .init(isLoading: isLoading.asObservable(),
                     authResult: authResult.asObservable())
    }
    
    public func popToRootViewController(value: RegisterEnum) {
        if value == .email { self.steps.accept(CodestackStep.exitRegister) }
        
        if value == .password { self.step1.steps.accept(CodestackStep.exitRegister) }
        
        if value == .nickname { self.step2.steps.accept(CodestackStep.exitRegister) }
    }
    
    
    public func isValid( _ password: Bool, _ isCorrect: Bool) -> Bool {
        if !password {
            self.step1toast(type: .error, content: "올바른 패스워드를 입력해주세요!")
            return false
        }
        if !isCorrect {
            self.step1toast(type: .error, content: "패스워드가 일치하지 않습니다!")
            return false
        }
        return true
    }
    
    public func isValid(email: Bool) -> Bool {
        if !email {
            self.toast(type: .error, content: "올바른 이메일을 입력해주세요!")
            return false
        }
        return true
    }
    
    public func isValid(_ nickname: Bool) -> Bool {
        if !nickname {
            self.step2toast(type: .error, content: "올바른 닉네임을 입력해주세요!")
            return false
        }
        return true
    }
    
    //MARK: - Util 함수
    
    private func toast(type: ToastStyle ,content: String) {
        steps.accept(CodestackStep.toastV2Message(type, content))
    }
    
    private func step1toast(type: ToastStyle ,content: String) {
        step1.steps.accept(CodestackStep.toastV2Message(type, content))
    }
    
    private func step2toast(type: ToastStyle ,content: String) {
        step2.steps.accept(CodestackStep.toastV2Message(type, content))
    }
    
    private func interactor() -> AuthResult {
        .init(sucess: true, content: "성공하셨습니다.")
    }
    private func errorInteractor(_ err: Error) -> AuthResult {
        if let err = err as? AuthFIRError {
            Log.debug("err: \(err)")
            return AuthResult(sucess: false, content: err.toMessage())
        }
        return AuthResult(sucess: false, content: "잠시후에 다시시도 해주세요")
    }
    
}
