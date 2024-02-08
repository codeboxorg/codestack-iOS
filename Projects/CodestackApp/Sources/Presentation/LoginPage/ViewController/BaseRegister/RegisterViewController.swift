
import UIKit
import SnapKit
import RxFlow
import RxRelay
import RxSwift
import Global
import Domain
import CommonUI

enum RError: Error{
    case invalidID
    case invalidpassword
    case incorrectpassword
    case invalidEmail
    case invalidNickname
    case none
}

class RegisterViewController: BaseRegisterVC {
        
    static func create(with dependency: RegisterViewModel) -> RegisterViewController {
        let vc = RegisterViewController(dependency: dependency) 
        return vc
    }
    
    private lazy var idField = UITextField().textFieldSetting(place: "아이디를 입력해주세요",tag: 0,vc: self)
    
    private let idFieldLabel =  UILabel().labelSetting("아이디")
    
    private lazy var emailField: UITextField = UITextField().textFieldSetting(place: "이메일을 입력해주세요",tag: 3,vc: self)
    
    private let emailFieldLabel = UILabel().largeLabel("이메일 입력")
    private let emailInfoLabel = UILabel().infoSetting("유효한 이메일 주소를 입력해주세요.")
    private let registerButton = RegisterButton(title: "다음")

    
    override func applyAttributes() {
        super.applyAttributes()
        view.backgroundColor = .systemBackground
    }
    
    override func addAutoLayout() {
        super.addAutoLayout()
        _addAutoLayout()
    }
    
    override func binding() {
        super.binding()
        let emailValid =
        emailField.rx.text.orEmpty
            .map { [weak self] value in
                guard let self else { throw RError.none }
                return self.isValid(pattern: PATTERN.email.pattern, text: value, view: self.emailField)
            }
        
        let nextTriger =
        registerButton.rx.tap
            .throttle(.seconds(1),latest: false, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .map { vc, _ in vc.makeUserInfo() }
        
        
        viewModel.emailBinding(input: .init(emailSubject: emailValid,
                                            nextTriger: nextTriger))
        
        #if DEBUG
        emailField.rx.text.onNext("gudghks56@gmail.com")
        #endif
    }
    
    private func idFieldBinding(){
        let _ =
        idField.rx.text.orEmpty
            .map { [weak self] value in
                guard let self else { throw RError.none }
                return self.isValid(pattern: PATTERN.id.pattern, text: value, view: self.idField)
            }
    }
    
    private func makeUserInfo() -> RegisterQuery {
        let email = emailField.text ?? ""
        return RegisterQuery(email: email)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let field = fields
        let tag = textField.tag
        
        if tag < field.count - 1 {
            field[tag + 1].becomeFirstResponder()
        } else {
            registerButton.sendActions(for: .touchUpInside)
        }
        textField.resignFirstResponder()
        
        return true
    }
}


//MARK: - Add AutoLayout
extension RegisterViewController{
    
    var labels: [UILabel] {
        [
            emailFieldLabel,
            emailInfoLabel
        ]
    }
    
    var fields: [UITextField] {
        [
            emailField
        ]
    }
    
    private func _addAutoLayout(){
        containerView.addSubview(registerButton)
        
        labels.forEach{ subview in
            containerView.addSubview(subview)
        }
        
        fields.forEach { subview in
            containerView.addSubview(subview)
        }
        
        emailFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(160)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        emailInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(emailFieldLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        emailField.snp.makeConstraints { make in
            make.top.equalTo(emailInfoLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
    }
}



extension UILabel{
    func largeLabel(_ text: String,
                     _ color: UIColor = CColor.label.color,
                     _ font: UIFont = 
                     UIFont.preferredFont(forTextStyle: .title2,
                                          compatibleWith: UITraitCollection(legibilityWeight: .bold)))
    -> UILabel {
        self.text = text
        self.textColor = color
        self.font = font
        return self
    }
    
    func labelSetting(_ text: String,
                      _ color: UIColor = CColor.label.color,
                      _ font: UIFont = UIFont.boldSystemFont(ofSize: 16))
    -> UILabel
    {
        self.text = text
        self.textColor = color
        self.font = font
        return self
    }
    
    func infoSetting(_ text: String,
                     _ color: UIColor = CColor.label.color.withAlphaComponent(0.7),
                      _ font: UIFont = UIFont.boldSystemFont(ofSize: 14))
    -> UILabel
    {
        self.numberOfLines = 2
        self.text = text
        self.textColor = color
        self.font = font
        return self
    }
}
