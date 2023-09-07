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
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let codestackLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "codeStack")
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
    
    private let rememberCheckBox: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: "rectangle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.rectangle"), for: .selected)
        return button
    }()
    
    private let rememberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "아이디 / 비밀번호 찾기"
        label.textColor = .label
        return label
    }()
    
    lazy var loginButton: LoginButton = {
        let button = LoginButton()
        button.tintColor = .white
        button.setTitle("로그인", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .powder_blue
        button.layer.cornerRadius = (button.titleLabel?.font.pointSize ?? 24) / 2
        return button
    }()
    
    
    private lazy var githubLoginButton: GitHubLoginButton = {
        let button = GitHubLoginButton(frame: .zero)
        return button
    }()
    
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.sky_blue, for: .normal)
        return button
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "하러가기"
        label.textColor = .label
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
    
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        addContentView()
        addAutoLayout()
    }
    
    func debugIDPwd(){
#if DEBUG
        idTextField.text = "test@codestack.co.kr"
        passwordTextField.text = "qwer1234!"
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
                    Toast.toastMessage("서버에서 응답이 오지 않습니다.: \(error)",offset: 30)
                }
                Log.debug("login button value : \(value)")
            }).disposed(by: disposeBag)
    }
    
    //MARK: emit RX button Tap Event to login
    func emitButtonEvents() -> Signal<LoginButtonType>{
        let git = githubLoginButton.rx.tap
            .map{ _ in return LoginButtonType.gitHub }
            .asSignal(onErrorJustReturn: .none)
        
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
    
    func registerEvent() -> Signal<Void>{
        registerButton.rx.tap.asSignal()
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
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
         codestackLogo,
         loginCheckButton,
         passwordCheckButton,
         rememberCheckBox,
         rememberLabel,
         loginButton,
         githubLoginButton,
         loginPlaceHolderView,
         passwordPlaceHolderView,
         registerButton,
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
        
        
        //        let bottomInset: CGFloat = 20
        // var subviewsHeight: CGFloat = (3 * idTop) + 10 + (5 * info_top_constant) + bottomInset
        // Update the containerView height constraint constant
        //        let containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0)
        //        [containerView.widthAnchor.constraint(equalTo: self.widthAnchor)].forEach{
        //            $0.isActive = true
        //        }
        //        containerViewHeightConstraint.isActive = true
        
        let heightAnchor = containerView.heightAnchor.constraint(equalToConstant: 300)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
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
            rememberLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
             rememberLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: info_top_constant)
        ])
        
        NSLayoutConstraint.activate([
            rememberCheckBox.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: info_top_constant),
            rememberCheckBox.widthAnchor.constraint(equalToConstant: 24),
            rememberCheckBox.heightAnchor.constraint(equalToConstant: 24),
            rememberCheckBox.trailingAnchor.constraint(equalTo: rememberLabel.leadingAnchor, constant: -(info_top_constant / 2))
        ])
        
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
            loginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant),
            loginButton.topAnchor.constraint(equalTo: rememberLabel.bottomAnchor, constant: info_top_constant),
            loginButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        NSLayoutConstraint.activate([
            loginProviderStackView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12),
            loginProviderStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leading_Trailing_contant),
            loginProviderStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -leading_Trailing_contant),
            loginProviderStackView.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        
        NSLayoutConstraint.activate([
            githubLoginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: leading_Trailing_contant),
            githubLoginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -leading_Trailing_contant),
            githubLoginButton.topAnchor.constraint(equalTo: loginProviderStackView.bottomAnchor,constant: info_top_constant),
            githubLoginButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
    
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: githubLoginButton.bottomAnchor, constant: info_top_constant - 8),
            registerButton.trailingAnchor.constraint(equalTo: infoLabel.leadingAnchor,constant: -6)
        ])
        
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: githubLoginButton.bottomAnchor, constant: info_top_constant),
            infoLabel.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor),
            infoLabel.centerXAnchor.constraint(equalTo: githubLoginButton.centerXAnchor,constant: 24),
            infoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,constant: -12)
        ])
      
        // Update the containerView height constraint
        
        // Calculate the height of the subviews
//        subviewsHeight += [codestackLogo,idTextField,passwordTextField,infoLabel,loginButton,rememberLabel,registerButton,loginProviderStackView].reduce(0) { $0 + $1.systemLayoutSizeFitting(CGSize(width: containerView.bounds.width, height: UIView.layoutFittingCompressedSize.height)).height
//        }
//
//        containerViewHeightConstraint.constant = subviewsHeight
    }
    
//
//    func containerViewLayoutIfNeeded(){
//        containerView.layoutIfNeeded()
//    }
}

