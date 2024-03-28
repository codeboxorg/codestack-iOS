//
//  RegisterView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/24.
//

import UIKit
import RxCocoa
import RxSwift
import CommonUI
import Then
import Domain

final class LoginView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let codestackLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "codeStack")?.resize(targetSize: CGSize(width: 50, height: 50))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let loginCheckButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "envelope"), for: .normal)
        view.tintColor = UIColor.label
        return view
    }()
    
    private let passwordCheckButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "lock"), for: .normal)
        view.tintColor = UIColor.label
        return view
    }()
    
    private lazy var idTextField: CustomTextField = {
        let textField = CustomTextField(frame: .zero, delegate: self,type: .ID)
        textField.layer.borderColor = UIColor.black.cgColor
        return textField
    }()
    
    private let buttomLayoutLine: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        return view
    }()
    private let buttomLayoutLine2: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        return view
    }()
    
    private let loginPlaceHolderView: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "이메일을 입력해주세요"
        label.textColor = .placeholderText
        return label
    }()
    
    private let passwordPlaceHolderView: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "비밀번호를 입력해주세요"
        label.textColor = .placeholderText
        return label
    }()
    
    private lazy var passwordTextField: CustomTextField = {
        let textField = CustomTextField(frame: .zero, delegate: self,type: .PassWord)
        textField.layer.borderColor = UIColor.black.cgColor
        return textField
    }()
    
    lazy var loginButton: LoginButton = {
        let button = LoginButton()
        button.tintColor = .white
        button.setTitle("로그인", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitleColor(UIColor.label, for: .normal)
        button.backgroundColor = dynamicSysBackground
        button.layer.cornerRadius = (button.titleLabel?.font.pointSize ?? 24) / 2
        return button
    }()
    
    let registerButton = RegisterButton.init(title: "회원가입").then { button in
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
    }
    
    private var idPlaceHolder_Center_Constraint: NSLayoutConstraint?
    private var passwordPlaceHolder_Center_Constraint: NSLayoutConstraint?
    private lazy var placeOffset: CGFloat = (self.idTextField.font?.pointSize ?? 32) + 8
    
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addContentView()
        addAutoLayout()
        
        registerButton.setTitleColor(.dynamicLabelColor, for: .normal)
        registerButton.backgroundColor = dynamicSysBackground
    }
    
    func debugIDPwd(){
#if DEBUG
        idTextField.text = "gudghks56@gmail.com"
        passwordTextField.text = "qwer159852"
        placeUpAnimation(idTextField, .ID)
        placeUpAnimation(idTextField, .PassWord)
#endif
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.endEditing(true)
    }
    
    
    func binding(loading: Driver<Result<Bool,Error>>){
        loading
            .drive(with: self, onNext: { owner, value in
                switch value{
                case .success(let value):
                    owner.loginButton.isLoading = value
                case .failure(let error):
                    owner.loginButton.isLoading = false
                    if let authError = error as? AuthFIRError,
                       case .FIRAuthErrorCodeInvalidCredential = authError {
                        Toast.toastMessage("정확한 아이디 비밀번호를 입력해주세요",offset: 30)
                    } else {
                        Toast.toastMessage("서버에서 응답이 오지 않습니다.: \(error)",offset: 30)
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    //MARK: emit RX button Tap Event to login
    func emitButtonEvents() -> Signal<LoginButtonType>{
        let email = loginButton.rx.tap
            .map{ [weak self] _ in
                if let id = self?.idTextField.text,
                   let pwd = self?.passwordTextField.text{
                    return LoginButtonType.email((id,pwd))
                }else{
                    return LoginButtonType.none
                }
            }
            .asSignal(onErrorJustReturn: .none)
        
        return Signal.merge([email]).asSignal(onErrorJustReturn: .none)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }

}


protocol TextFieldAnimationDelegate: AnyObject {
    func placeUpAnimation(_ textField: CustomTextField,_ type: CustomTextField.FieldType)
    
    func placeDownAnimation(_ textField: CustomTextField,_ type: CustomTextField.FieldType)
}



extension LoginView: TextFieldAnimationDelegate {
    func placeUpAnimation(_ textField: CustomTextField, _ type: CustomTextField.FieldType) {
        switch type {
        case .ID:
            changePlaceOffsetAnimation(idPlaceHolder_Center_Constraint!,
                                       -placeOffset)
        case .PassWord:
            changePlaceOffsetAnimation(passwordPlaceHolder_Center_Constraint!,
                                       -placeOffset)
        case .none:
            fatalError("downAnimation error")
        }
    }
    
    func placeDownAnimation(_ textField: CustomTextField, _ type: CustomTextField.FieldType) {
        switch type {
        case .ID:
            changePlaceOffsetAnimation(idPlaceHolder_Center_Constraint!,
                                       placeOffset)
        case .PassWord:
            changePlaceOffsetAnimation(passwordPlaceHolder_Center_Constraint!,
                                       placeOffset)
        case .none:
            fatalError("downAnimation error")
        }
    }
}


extension LoginView {
    
    func changePlaceOffsetAnimation(_ layout: NSLayoutConstraint,_ offset: CGFloat){
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.05,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 2,
                       options: .allowUserInteraction,
                       animations: {
            layout.constant += offset
            self.loginPlaceHolderView.text = "이메일"
            self.layoutIfNeeded()
        },completion: {  _ in
            
        })
    }
    
    
    func addContentView(){
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        [idTextField,
         buttomLayoutLine,
         passwordTextField,
         buttomLayoutLine2,
         codestackLogo,
         loginCheckButton,
         passwordCheckButton,
         loginButton,
         loginPlaceHolderView,
         passwordPlaceHolderView,
         registerButton
        ].forEach{
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func addAutoLayout(){
        
        let leading_Trailing_contant: CGFloat = 30
        let idTop: CGFloat = 30
        let idHeight: CGFloat = 50
        let place_constant: CGFloat = 8
        let lineHeight: CGFloat = 4
        let button_Width_height: CGFloat = 30
        let info_top_constant: CGFloat = 16
        
        let heightAnchor = containerView.heightAnchor.constraint(equalToConstant: 300)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            heightAnchor
        ])
        
        heightAnchor.priority = .defaultLow

        
        
        NSLayoutConstraint.activate([
            codestackLogo.topAnchor.constraint(equalTo: containerView.topAnchor, constant: idTop),
            codestackLogo.widthAnchor.constraint(equalToConstant: 60),
            codestackLogo.heightAnchor.constraint(equalToConstant: 60),
            codestackLogo.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            idTextField.topAnchor.constraint(equalTo: codestackLogo.bottomAnchor, constant: idTop + 10),
            idTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
            idTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant - button_Width_height),
            idTextField.heightAnchor.constraint(equalToConstant: idHeight)
        ])
        
        idPlaceHolder_Center_Constraint = loginPlaceHolderView.centerYAnchor.constraint(equalTo: idTextField.centerYAnchor)
        
        NSLayoutConstraint.activate([
            loginPlaceHolderView.leadingAnchor.constraint(equalTo: idTextField.leadingAnchor,constant: place_constant),
            idPlaceHolder_Center_Constraint!
        ])
        
        NSLayoutConstraint.activate([
            buttomLayoutLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
            buttomLayoutLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant),
            buttomLayoutLine.centerYAnchor.constraint(equalTo: idTextField.bottomAnchor),
            buttomLayoutLine.heightAnchor.constraint(equalToConstant: lineHeight)
        ])
        
        
        NSLayoutConstraint.activate([
            loginCheckButton.leadingAnchor.constraint(equalTo: idTextField.trailingAnchor, constant: place_constant),
            loginCheckButton.centerYAnchor.constraint(equalTo: idTextField.centerYAnchor),
            loginCheckButton.widthAnchor.constraint(equalToConstant: button_Width_height),
            loginCheckButton.heightAnchor.constraint(equalToConstant: button_Width_height)
        ])
        
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: idTextField.bottomAnchor, constant: idTop),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant - button_Width_height),
            passwordTextField.heightAnchor.constraint(equalToConstant: idHeight)
        ])
        
        
        passwordPlaceHolder_Center_Constraint = passwordPlaceHolderView.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor)
        
        NSLayoutConstraint.activate([
            passwordPlaceHolderView.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor,constant: place_constant),
            passwordPlaceHolder_Center_Constraint!
        ])
        
        NSLayoutConstraint.activate([
            buttomLayoutLine2.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
            buttomLayoutLine2.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant),
            buttomLayoutLine2.centerYAnchor.constraint(equalTo: passwordTextField.bottomAnchor),
            buttomLayoutLine2.heightAnchor.constraint(equalToConstant: lineHeight)
        ])
        
        NSLayoutConstraint.activate([
            passwordCheckButton.leadingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: place_constant),
            passwordCheckButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            passwordCheckButton.widthAnchor.constraint(equalToConstant: button_Width_height),
            passwordCheckButton.heightAnchor.constraint(equalToConstant: button_Width_height)
        ])
        
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
            loginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant),
            loginButton.topAnchor.constraint(equalTo: passwordCheckButton.bottomAnchor, constant: 30),
            loginButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    
        NSLayoutConstraint.activate([
            registerButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: leading_Trailing_contant),
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: info_top_constant - 8),
            registerButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -leading_Trailing_contant),
            registerButton.heightAnchor.constraint(equalToConstant: 55),
            registerButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
}

