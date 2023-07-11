//
//  RegisterView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/24.
//

import UIKit
import RxCocoa
import RxSwift


class LoginView: UIView{
    
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        var font = UIFont.preferredFont(forTextStyle: .headline)
        font = font.withSize(30)
        label.font = font
        label.textColor = .white
        label.text = "Login"
        return label
    }()
    
    private lazy var loginCheckButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "envelope"), for: .normal)
        view.tintColor = UIColor.white
        return view
    }()
    
    private lazy var passwordCheckButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "lock"), for: .normal)
        view.tintColor = UIColor.white
        return view
    }()
    
    private lazy var idTextField: CustomTextField = {
        let textField = CustomTextField(frame: .zero, delegate: self,type: .ID)
        textField.layer.borderColor = UIColor.black.cgColor
        return textField
    }()
    
    private lazy var buttomLayoutLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private lazy var buttomLayoutLine2: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var loginPlaceHolderView: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "이메일을 입력해주세요"
        label.textColor = .white
        return label
    }()
    
    private lazy var passwordPlaceHolderView: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "비밀번호를 입력해주세요"
        label.textColor = .white
        return label
    }()
    
    private lazy var passwordTextField: CustomTextField = {
        let textField = CustomTextField(frame: .zero, delegate: self,type: .PassWord)
        textField.layer.borderColor = UIColor.black.cgColor
        return textField
    }()
    
    private lazy var rememberCheckBox: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "rectangle"), for: .selected)
        button.setImage(UIImage(systemName: "checkmark.rectangle"), for: .selected)
        return button
    }()
    
    private lazy var rememberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "아이디 / 비밀번호 찾기"
        label.textColor = .white
        return label
    }()
    
    lazy var loginButton: LoginButton = {
        let button = LoginButton()
        button.tintColor = .white
        button.setTitle("Log in", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = (button.titleLabel?.font.pointSize ?? 24) / 2
        //        button.addTarget(self, action: #selector(addActions(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(isValidLogin(_:)), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var githubLoginButton: GitHubLoginButton = {
        let button = GitHubLoginButton(frame: .zero)
        button.addTarget(self, action: #selector(gitLogin(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "회원가입 하실래여?"
        label.textColor = .white
        return label
    }()
    
    lazy var loginProviderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        return stackView
    }()
    
    
    private var idPlaceHolder_Center_Constraint: NSLayoutConstraint?
    private var passwordPlaceHolder_Center_Constraint: NSLayoutConstraint?
    private lazy var placeOffset: CGFloat = (self.idTextField.font?.pointSize ?? 32) + 8
    
    
//    weak var loginViewModel: (any LoginViewModelProtocol)?
    
    var completion: ((Bool) -> ())?
    var moveTomain: (() -> ())?
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addContentView()
        addAutoLayout()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.endEditing(true)
    }
    
    
    func binding(loading: Driver<Bool>){
        loading
            .drive(with: self, onNext: { owner, value in
                owner.loginButton.isLoading = value
                Log.debug("login button value : \(value)")
            }).disposed(by: disposeBag)
    }
    
    //MARK: emit RX button Tap Event to login
    func emitButtonEvents() -> Signal<LoginButtonType>{
        
        let git = githubLoginButton.rx.tap
            .map{ _ in return LoginButtonType.gitHub }
            .asSignal(onErrorJustReturn: .none)
        
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
//            guard let self else {return}
//            self.loginButton.sendActions(for: .touchUpInside)
        })
        #endif
        
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
        
        return Signal.merge([git,email])
            .asSignal(onErrorJustReturn: .none)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    
    @objc func gitLogin(_ sender: UIButton){
        do{
            //            try loginViewModel?.requestOAuth()
        }catch{
            assert(false,"\(error)")
        }
    }
    
    @objc func addActions(_ sender: UIButton){
        completion?(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.moveTomain?()
        })
    }
    
    @objc func isValidLogin(_ sender: UIButton){
        
    }
}


protocol TextFieldAnimationDelegate: AnyObject{
    func placeUpAnimation(_ textField: CustomTextField,_ type: CustomTextField.FieldType)
    
    func placeDownAnimation(_ textField: CustomTextField,_ type: CustomTextField.FieldType)
}



extension LoginView: TextFieldAnimationDelegate{
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
         loginLabel,
         loginCheckButton,
         passwordCheckButton,
         rememberCheckBox,
         rememberLabel,
         loginButton,
         githubLoginButton,
         loginPlaceHolderView,
         passwordPlaceHolderView,
         infoLabel,
         loginProviderStackView
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
        
        
        let bottomInset: CGFloat = 20
        var subviewsHeight: CGFloat = (3 * idTop) + 10 + (4 * info_top_constant) + bottomInset
        
        // Update the containerView height constraint constant
        let containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0)
        [containerView.widthAnchor.constraint(equalTo: self.widthAnchor)].forEach{
            $0.isActive = true
        }
        
        containerViewHeightConstraint.isActive = true
        
        
        [loginLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: idTop),
         loginLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0)].forEach{
            $0.isActive = true
        }
        
        
        [idTextField.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: idTop + 10),
         idTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
         idTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant - button_Width_height),
         idTextField.heightAnchor.constraint(equalToConstant: idHeight)].forEach{
            $0.isActive = true
        }
        
        idPlaceHolder_Center_Constraint = loginPlaceHolderView.centerYAnchor.constraint(equalTo: idTextField.centerYAnchor)
        
        [loginPlaceHolderView.leadingAnchor.constraint(equalTo: idTextField.leadingAnchor,constant: place_constant),
         idPlaceHolder_Center_Constraint!].forEach{
            $0.isActive = true
        }
        
        
        
        [  buttomLayoutLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
           buttomLayoutLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant),
           buttomLayoutLine.centerYAnchor.constraint(equalTo: idTextField.bottomAnchor),
           buttomLayoutLine.heightAnchor.constraint(equalToConstant: lineHeight)].forEach{
            $0.isActive = true
        }
        
        
        [loginCheckButton.leadingAnchor.constraint(equalTo: idTextField.trailingAnchor, constant: place_constant),
         loginCheckButton.centerYAnchor.constraint(equalTo: idTextField.centerYAnchor),
         loginCheckButton.widthAnchor.constraint(equalToConstant: button_Width_height),
         loginCheckButton.heightAnchor.constraint(equalToConstant: button_Width_height)].forEach{
            $0.isActive = true
        }
        
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: idTextField.bottomAnchor, constant: idTop),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant - button_Width_height),
            passwordTextField.heightAnchor.constraint(equalToConstant: idHeight)
        ])
        
        
        
        passwordPlaceHolder_Center_Constraint = passwordPlaceHolderView.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor)
        
        [passwordPlaceHolderView.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor,constant: place_constant),
         passwordPlaceHolder_Center_Constraint!].forEach{
            $0.isActive = true
        }
        
        [  buttomLayoutLine2.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
           buttomLayoutLine2.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant),
           buttomLayoutLine2.centerYAnchor.constraint(equalTo: passwordTextField.bottomAnchor),
           buttomLayoutLine2.heightAnchor.constraint(equalToConstant: lineHeight)].forEach{
            $0.isActive = true
        }
        
        
        [passwordCheckButton.leadingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: place_constant),
         passwordCheckButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
         passwordCheckButton.widthAnchor.constraint(equalToConstant: button_Width_height),
         passwordCheckButton.heightAnchor.constraint(equalToConstant: button_Width_height)].forEach{
            $0.isActive = true
        }
        
        [rememberLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
         rememberLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: info_top_constant)].forEach{
            $0.isActive = true
        }
        
        
        [rememberCheckBox.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: info_top_constant),
         rememberCheckBox.trailingAnchor.constraint(equalTo: rememberLabel.leadingAnchor, constant: -(info_top_constant / 2))].forEach{
            $0.isActive = true
        }
        
        [loginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
         loginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant),
         loginButton.topAnchor.constraint(equalTo: rememberLabel.bottomAnchor, constant: info_top_constant)].forEach{
            $0.isActive = true
        }
        
        NSLayoutConstraint.activate([
            githubLoginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: leading_Trailing_contant),
            githubLoginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -leading_Trailing_contant),
            githubLoginButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor,constant: info_top_constant),
            githubLoginButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        
        NSLayoutConstraint.activate([
            loginProviderStackView.topAnchor.constraint(equalTo: githubLoginButton.bottomAnchor, constant: 12),
            loginProviderStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
            loginProviderStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant),
            loginProviderStackView.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        
        
        [infoLabel.topAnchor.constraint(equalTo: loginProviderStackView.bottomAnchor, constant: info_top_constant),
         infoLabel.centerXAnchor.constraint(equalTo: loginProviderStackView.centerXAnchor)].forEach{
            $0.isActive = true
        }
        
        // Update the containerView height constraint
        
        // Calculate the height of the subviews
        subviewsHeight += [loginLabel,idTextField,passwordTextField,infoLabel,loginButton,rememberLabel,loginProviderStackView].reduce(0) { $0 + $1.systemLayoutSizeFitting(CGSize(width: containerView.bounds.width, height: UIView.layoutFittingCompressedSize.height)).height
        }
        
        containerViewHeightConstraint.constant = subviewsHeight
    }
    
    
    
    
    func containerViewLayoutIfNeeded(){
        containerView.layoutIfNeeded()
    }
}

