//
//  EditProfileViewController.swift
//  CodestackApp
//
//  Created by 박형환 on 1/15/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Global
import CommonUI
import RxGesture

final class EditProfileViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "xmark")?
            .resize(targetSize: CGSize(width: 24, height: 24))
            .withTintColor(.label)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = CodestackAppAsset.codeStack.image
        imageView.tintColor = UIColor.gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    private let emailFieldLabel: UILabel = {
        return UILabel().labelSetting("이메일")
    }()
    
    private lazy var emailField: UITextField = {
        let field = UITextField().textFieldSetting(place: "이메일을 입력해주세요",tag: 4,vc: self)
        field.layer.borderWidth = 0
        field.isEnabled = false
        field.tintColor = .label
        return field
    }()
    
    private let nickNameFieldLabel: UILabel = {
        return UILabel().labelSetting("닉네임")
    }()
    
    private lazy var nickNameField: UITextField = {
        let field = UITextField().textFieldSetting(place: "닉네임을 입력해주세요",tag: 4,vc: self)
        field.tintColor = .label
        return field
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정하기", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let imageIndicator = UIActivityIndicatorView(style: .medium)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let photoViewController = PhotoPickerViewController()
    
    static func create(with dp: EditProfileViewModel) -> EditProfileViewController {
        let vc = EditProfileViewController.init(editViewModel: dp)
        return vc
    }
    
    init(editViewModel: EditProfileViewModel) {
        self.editViewModel = editViewModel
        super.init(nibName: nil, bundle: nil)
        
        self.photoViewController.action = { [weak self] image, error in
            DispatchQueue.main.async {
                if let image = image as? UIImage {
                    let data = image.compress(to: 500)
                    self?.imageSelected.onNext(data)
                    self?.imageIndicator.startAnimating()
                    self?.imageView.load(data: data, completion: { _ in
                        self?.imageIndicator.stopAnimating()
                    })
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let editViewModel: EditProfileViewModel
    private var disposeBag = DisposeBag()
    
    let emailSubject = BehaviorSubject<Bool>(value: false)
    let nickNameSubject = BehaviorSubject<Bool>(value: false)
    let imageSelected = PublishSubject<Data>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAutoLayout()
        binding()
    }
    
    lazy var editButtonBinder = Binder<Bool>(self) { target, value in
        if value {
            target.editButton.isEnabled = false
            target.editButton.setTitle("", for: .normal)
            target.activityIndicator.startAnimating()
        } else {
            target.editButton.isEnabled = true
            target.editButton.setTitle("수정", for: .normal)
            target.activityIndicator.stopAnimating()
        }
    }
    
    private func binding() {
        imageView.rx.tapGesture().when(.recognized)
            .subscribe(with: self, onNext: { vc, _ in
                vc.photoViewController.checkAuthorize(vc)
            }).disposed(by: disposeBag)
        
        editViewModel.member
            .take(1)
            .bind(with: self, onNext: { vc, member in
                vc.imageView.image = UIImage(data: member.image)
                vc.emailField.text = member.email
                vc.nickNameField.text = member.nickName
            }).disposed(by: disposeBag)
        
        
        dismissButton.rx.tap
            .subscribe(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        emailField.rx.text
            .distinctUntilChanged()
            .subscribe(with: self, onNext: { vc, value in
            }).disposed(by: disposeBag)
        
        let emailValid =
        emailField.rx.text.orEmpty
            .startWith(emailField.text ?? "")
            .withUnretained(self)
            .map { vc, value in
                vc.isValid(pattern: PATTERN.email.pattern, text: value, view: vc.emailField)
            }
        
        let nicknameValid =
        nickNameField.rx.text.orEmpty
            .startWith(nickNameField.text ?? "")
            .withUnretained(self)
            .map { vc, value in
                vc.isValid(pattern: PATTERN.nickname.pattern, text: value, view: vc.nickNameField)
            }
        
        let validState
        =
        Observable.combineLatest(emailValid, nicknameValid)
            .map { EditProfileViewModel.ValidState.init(email: $0, nickname: $1) }
            .asDriver(onErrorJustReturn: .init())
        
        let editEvent
        =
        editButton.rx.tap
            .withUnretained(self)
            .compactMap { vc, _ in
                EditViewModel(imageURL: "",
                              image: vc.imageView.image?.compress(to: 500) ?? Data(),
                              email: vc.emailField.text ?? "",
                              nickName: vc.nickNameField.text ?? "")
            }.asSignal(onErrorJustReturn: .sample)
        
        let input = EditProfileViewModel.Input(profileImageSelected: imageSelected.asObservable(),
                                               editProfileEvent: editEvent,
                                               validState: validState)
        let output = editViewModel.transform(input: input)
        
        output.editButtonLoading
            .bind(to: editButtonBinder)
            .disposed(by: disposeBag)
    }
    
    private func addAutoLayout() {
        view.backgroundColor = .systemBackground
        [
            imageView,
            titleLabel,
            dismissButton,
            emailFieldLabel,
            emailField,
            nickNameFieldLabel,
            nickNameField,
            editButton
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        editButton.addSubview(activityIndicator)
        
        imageIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(imageIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            dismissButton.widthAnchor.constraint(equalToConstant: 24),
            dismissButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            imageView.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 95),
            imageView.heightAnchor.constraint(equalToConstant: 95)
        ])
        
        NSLayoutConstraint.activate([
            emailFieldLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            emailFieldLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
        
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: emailFieldLabel.bottomAnchor, constant: 8),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            nickNameFieldLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            nickNameFieldLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
        
        NSLayoutConstraint.activate([
            nickNameField.topAnchor.constraint(equalTo: nickNameFieldLabel.bottomAnchor, constant: 8),
            nickNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nickNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -24),
            nickNameField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(equalTo: nickNameField.bottomAnchor, constant: 24),
            editButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            editButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: editButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: editButton.centerYAnchor),
            
            imageIndicator.centerXAnchor.constraint(equalTo: editButton.centerXAnchor),
            imageIndicator.centerYAnchor.constraint(equalTo: editButton.centerYAnchor)
        ])
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
