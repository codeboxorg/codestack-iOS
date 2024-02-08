//
//  AdditionalInfoViewController.swift
//  CodestackApp
//
//  Created by 박형환 on 1/19/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import SnapKit
import CommonUI

final class AdditionalInfoViewController: BaseRegisterVC {
    private let registerButton = RegisterButton(title: "회원가입")
    private let nicknameLabel = UILabel().labelSetting("닉네임")
    private lazy var nickNameField = UITextField().textFieldSetting(place: "닉네임을 입력해주세요",
                                                                    tag: 0,
                                                                    vc: self)
    
    static func create(with dependency: RegisterViewModel) -> AdditionalInfoViewController {
        let baseVC = AdditionalInfoViewController.init(dependency: dependency)
        return baseVC
    }
    
    override func addAutoLayout() {
        super.addAutoLayout()
        _addAutoLayout()
    }
    
    override func applyAttributes() {
        view.backgroundColor = UIColor.systemBackground
        statusViewMedium.setProgress(1, animated: false)
    }
    
    override func binding() {
        super.binding()
        let nicknameValid =
        nickNameField.rx.text.orEmpty
            .map { [weak self] value in
                guard let self else { throw RError.none }
                return self.isValid(pattern: PATTERN.nickname.pattern, text: value, view: self.nickNameField)
            }
        
        let registerEvent =
        registerButton.rx.tap
            .withUnretained(self)
            .compactMap { vc, _ in
                vc.nickNameField.text
            }
            .map { RegisterQuery(nickname: $0)}
        
        let output = viewModel.registerEvent(input: .init(nickNameSubject: nicknameValid.asObservable(),
                                                     registerEvent: registerEvent))
        output.isLoading
            .bind(to: registerButton.binder)
            .disposed(by: disposeBag)
        
        #if DEBUG
        nickNameField.rx.text.onNext("hwan")
        #endif
    }
    
    var fields: [UITextField] {
        [nickNameField]
    }
}

extension RegisterButton {
    var binder: Binder<Bool> {
        Binder(self) { target, flag in
            if flag {
                target.activityIndicator.startAnimating()
                target.activityIndicator.isHidden = false
                target.isEnabled = false
                target.setTitle("", for: .normal)
            } else {
                target.activityIndicator.stopAnimating()
                target.activityIndicator.isHidden = true
                target.isEnabled = true
                target.setTitle("회원가입", for: .normal)
            }
        }
    }
}


extension AdditionalInfoViewController {
    private func _addAutoLayout() {
        [
            nicknameLabel,
            nickNameField,
            registerButton
        ].forEach { containerView.addSubview($0) }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(statusViewMedium.snp.bottom).offset(90)
            make.leading.equalToSuperview().inset(32)
        }
        
        nickNameField.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(fields.last!.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
    }
}

extension AdditionalInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
