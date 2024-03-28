//
//  EmailPwdViewController.swift
//  CodestackApp
//
//  Created by 박형환 on 1/19/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import RxFlow
import RxCocoa
import RxSwift
import SnapKit
import Domain
import CommonUI

final class PasswordViewController: BaseRegisterVC {
    
    private let pwdInfo: String = "비밀번호는 8자에서 25자까지의 길이여야 합니다."
    private let pwdtitle: String = "비밀번호를 입력해주세요"
    private let pwdPlace: String = "비밀번호"
    private let correct: String = "비밀번호 확인"
    private let correctInfo: String = ""
    private let isCorrectField: String = "비밀번호를 한번 더 입력해주세요"
    
    private lazy var passwordField = UITextField().textFieldSetting(place: pwdPlace,
                                                                    tag: 0,
                                                                    vc: self,
                                                                    secure: true)
    
    private lazy var passwordFieldLabel: UILabel = UILabel().largeLabel(pwdtitle)
    private lazy var passwordInfoLabel: UILabel = UILabel().infoSetting(pwdInfo)
    
    private lazy var isCorrectPasswordField = UITextField().textFieldSetting(place: isCorrectField,
                                                                             tag: 1,
                                                                             vc: self,
                                                                             secure: true)
    
    private lazy var isCorrectPasswordFieldLabel = UILabel().largeLabel(correct)
    private lazy var isCorrectInfoLabel: UILabel = UILabel().infoSetting(correctInfo)
    private let registerButton = RegisterButton(title: "다음")
    
    private let passwordReslut = PublishSubject<Bool>()
    private let corretReslut = PublishSubject<Bool>()
    
    static func create(with dependency: RegisterViewModel) -> PasswordViewController {
        let baseVC = PasswordViewController.init(dependency: dependency)
        return baseVC
    }
    
    override func addAutoLayout() {
        super.addAutoLayout()
        _addAutoLayout()
    }
    
    override func applyAttributes() {
        view.backgroundColor = UIColor.systemBackground
        statusViewMedium.setProgress(2 / 3, animated: false)
    }
    
    override func binding() {
        super.binding()
        _binding()
    }
}

extension PasswordViewController {
    private func _binding() {
        let passwordValid =
        passwordField.rx.text.orEmpty
            .share(replay: 1)
        
        let checkedPassword = passwordValid.map { [weak self] value in
            guard let self else { throw RError.none }
            return self.isValid(pattern: PATTERN.password.pattern, text: value, view: self.passwordField)
        }.do(onNext: { [weak self] flag in
            self?.passwordReslut.onNext(flag)
        })
        
        passwordReslut
            .skip(1)
            .subscribe(with: self, onNext: { vc, value in
                vc.passwordInfoLabel.textColor = value ? UIColor.green : UIColor.red
                vc.passwordInfoLabel.text = value ? "알맞은 비밀번호 입니다!" : "\(vc.pwdInfo)"
            }).disposed(by: disposeBag)
        
        corretReslut
            .subscribe(with: self, onNext: { vc, value in
                vc.isCorrectInfoLabel.textColor = value ? UIColor.green : UIColor.red
                vc.isCorrectInfoLabel.text = value ? "일치합니다!" : "비밀번호가 일치하지 않습니다."
            }).disposed(by: disposeBag)
        
        let isCorrectCheck =
        isCorrectPasswordField.rx.text.orEmpty
            .map { [weak self] value in
                guard let self else { throw RError.none }
                if value.isEmpty {
                    self.markColorWhenVaild(type: .empty, view: self.isCorrectPasswordField)
                }
                return value
            }
        
        let isCorrectAndEqual = isCorrectCheck
            .withUnretained(self)
            .skip(1)
            .withLatestFrom(passwordValid) { value , original in
                let (vc, value) = value
                if value.isEmpty { return false }
                let result = (value == original)
                let type: Valid = result ? .corret : .wrong
                vc.markColorWhenVaild(type: type, view: vc.isCorrectPasswordField )
                return result
            }.do(onNext: { [weak self] flag in
                self?.corretReslut.onNext(flag)
            })
        
        let nextTriger =
        registerButton.rx.tap
            .withUnretained(self)
            .map { vc, _ in
                let pwd = vc.passwordField.text ?? ""
                let correctPwd = vc.isCorrectPasswordField.text ?? ""
                return RegisterQuery(password: pwd, isCorrectPassWord: correctPwd)
        }
        
        viewModel.passwordBinding(input:
                .init(passwordSubject: checkedPassword.asObservable(),
                      isCorrectPasswordSubject: isCorrectAndEqual.asObservable(),
                      nextTriger: nextTriger.asObservable() )
        )
        
        #if DEBUG
        passwordField.rx.text.onNext("qwer159852")
        isCorrectPasswordField.rx.text.onNext("qwer159852")
        #endif
    }
}

extension PasswordViewController {
    var labels: [UILabel] {
        [
            passwordFieldLabel,
            passwordInfoLabel,
            isCorrectPasswordFieldLabel,
            isCorrectInfoLabel
        ]
    }
    var fields: [UITextField] {
        [
            passwordField,
            isCorrectPasswordField
        ]
    }
    
    private func _addAutoLayout() {
        labels.forEach { containerView.addSubview($0) }
        fields.forEach { containerView.addSubview($0) }
        containerView.addSubview(registerButton)
        
        passwordFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(130)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        passwordInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordFieldLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        passwordField.snp.makeConstraints { make in
            make.top.equalTo(passwordInfoLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        isCorrectPasswordFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        isCorrectInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(isCorrectPasswordFieldLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        isCorrectPasswordField.snp.makeConstraints { make in
            make.top.equalTo(isCorrectInfoLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(isCorrectPasswordField.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
    }
}

extension PasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let field = fields
        let tag = textField.tag
        
        if tag < field.count - 1 {
            field[tag + 1].becomeFirstResponder()
        } else {
            textField.endEditing(true)
        }
        textField.resignFirstResponder()
        
        return true
    }
}
