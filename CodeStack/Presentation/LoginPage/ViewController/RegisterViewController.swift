
import UIKit
import SnapKit
import RxFlow
import RxRelay
import RxSwift


enum RError: Error{
    case invalidID
    case invalidpassword
    case incorrectpassword
    case invalidEmail
    case invalidNickname
    case none
}

class RegisterViewController: UIViewController, Stepper{
    
    var steps = PublishRelay<Step>()
    
    
    enum Valid {
        case empty
        case corret
        case wrong
    }
    
    private var service: AuthServiceType?
    
    static func create(with dependency: AuthServiceType) -> RegisterViewController {
        let vc = RegisterViewController()
        vc.service = dependency
        return vc
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var idField: UITextField = {
        return UITextField().textFieldSetting(place: "아이디를 입력해주세요",tag: 0,vc: self)
    }()
    
    private let idFieldLabel: UILabel = {
        return UILabel().labelSetting("아이디")
    }()
    
    private lazy var passwordField: UITextField = {
        return UITextField().textFieldSetting(place: "비밀번호를 입력해주세요",
                                              tag: 1,
                                              vc: self,
                                              secure: true)
    }()
    
    private let passwordFieldLabel: UILabel = {
        return UILabel().labelSetting("비밀번호")
    }()
    
    private lazy var isCorrectPasswordField: UITextField = {
        return UITextField().textFieldSetting(place: "비밀번호를 한번 더 입력해주세요",
                                              tag: 2,
                                              vc: self,
                                              secure: true)
    }()
    
    private let isCorrectPasswordFieldLabel: UILabel = {
        return UILabel().labelSetting("비밀번호 확인")
    }()
    
    private lazy var emailField: UITextField = {
        return UITextField().textFieldSetting(place: "이메일을 입력해주세요",tag: 3,vc: self)
    }()
    
    
    private let emailFieldLabel: UILabel = {
        return UILabel().labelSetting("이메일")
    }()
    
    private lazy var nickNameField: UITextField = {
        return UITextField().textFieldSetting(place: "닉네임을 입력해주세요",tag: 4,vc: self)
    }()
    
    
    private let nickNameFieldLabel: UILabel = {
        return UILabel().labelSetting("닉네임")
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.tintColor = CColor.sky_blue.color
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(CColor.label.color, for: .normal)
        button.backgroundColor = CColor.powder_blue.color
        button.layer.cornerRadius = 12
        return button
    }()
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        
        addAutoLayout()
        
        //MARK: - Binding Logic
        keyboardBinding()
        idFieldBinding()
        passwordFieldBinding()
        emailFieldBinding()
        nicknameFieldBinding()
        
        registerEvent()
    }
    
    
    //MARK: - Binding Logic
    func keyboardBinding(){
        let keyboard = KeyBoardManager.shared.getKeyBoardLifeCycle()
        
        keyboard
            .keyBoardAppear
            .asInfallible()
            .subscribe(with: self,onNext: { vc, rect in
                vc.scrollView.isScrollEnabled = true
                print("appaer")
                vc.remakeScrollViewLayout(value: rect.height)
            }).disposed(by: disposeBag)
        
        keyboard
            .keyBoardDissapear
            .asInfallible()
            .subscribe(with: self,onNext: { vc, _ in
                vc.scrollView.isScrollEnabled = false
                print("disappaer")
                vc.remakeScrollViewLayout(value: 0)
            }).disposed(by: disposeBag)
    }
    
    let idSubject = BehaviorSubject<Bool>(value: false)
    let passwordSubject = BehaviorSubject<Bool>(value: false)
    let isCorrectPasswordSubject = BehaviorSubject<Bool>(value: false)
    let emailSubject = BehaviorSubject<Bool>(value: false)
    let nickNameSubject = BehaviorSubject<Bool>(value: false)
    
    private func idFieldBinding(){
        let pattern = "^[a-z]+[a-z0-9]{4,19}$"
        
        let idisValid =
        idField.rx.text.orEmpty
            .map { [weak self] value in
                guard let self else { throw RError.none }
                return self.isValid(pattern: pattern, text: value, view: self.idField)
            }
        //            .share(replay: 1)
        
        idisValid
            .bind(with: self, onNext: { vc, value in
                vc.idSubject.onNext(value)
            })
            .disposed(by: disposeBag)
    }
    
    private func passwordFieldBinding() {
        
        let pattern = "^(?=.*[a-zA-Z])(?=.*[0-9]).{8,25}$"
        
        let passwordValid =
        passwordField.rx.text.orEmpty
            .share(replay: 1)
        
        
        let checkedPassword = passwordValid.map{ [weak self] value in
            guard let self else { throw RError.none }
            return self.isValid(pattern: pattern, text: value, view: self.passwordField)
        }
        
        let isCorrectCheck =
        isCorrectPasswordField.rx.text.orEmpty
            .map { [weak self] value in
                guard let self else { throw RError.none }
                if value.isEmpty {
                    self.markColorWhenVaild(type: .empty, view: self.isCorrectPasswordField)
                }
                return value
            }
        
        isCorrectCheck
            .withUnretained(self)
            .skip(1)
            .withLatestFrom(passwordValid) { value , original in
                let (vc, value) = value
                if value.isEmpty { return false }
                let result = (value == original)
                result
                ?
                vc.markColorWhenVaild(type: .corret, view: vc.isCorrectPasswordField )
                :
                vc.markColorWhenVaild(type: .wrong, view: vc.isCorrectPasswordField )
                return result
            }
            .subscribe(with: self,onNext: { vc, isCorrect in
                vc.isCorrectPasswordSubject.onNext(isCorrect)
            }).disposed(by: disposeBag)
        
        
        checkedPassword
            .bind(with: self, onNext: { vc, value in
                vc.passwordSubject.onNext(value)
            }).disposed(by: disposeBag)
    }
    
    private func emailFieldBinding() {
        let pattern =  "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        
        let emailValid =
        emailField.rx.text.orEmpty
            .map { [weak self] value in
                guard let self else { throw RError.none }
                return self.isValid(pattern: pattern, text: value, view: self.emailField)
            }
        //            .share(replay: 1)
        
        emailValid
            .bind(with: self, onNext: { vc, value in
                vc.emailSubject.onNext(value)
            }).disposed(by: disposeBag)
    }
    
    private func nicknameFieldBinding() {
        
        let pattern =  "^[ㄱ-ㅎ가-힣a-zA-Z0-9]{2,20}$"
        
        let nicknameValid =
        nickNameField.rx.text.orEmpty
            .map { [weak self] value in
                guard let self else { throw RError.none }
                return self.isValid(pattern: pattern, text: value, view: self.nickNameField)
            }
        //            .share(replay: 1)
        
        nicknameValid
            .bind(with: self, onNext: { vc, value in
                vc.nickNameSubject.onNext(value)
            }).disposed(by: disposeBag)
    }
    
    
    func registerEvent() {
        
        let register = registerButton.rx.tap
        
        let combineLatest = Observable.combineLatest(idSubject.asObservable(),
                                                     passwordSubject.asObservable(),
                                                     isCorrectPasswordSubject.asObservable(),
                                                     emailSubject.asObservable(),
                                                     nickNameSubject.asObservable())
        
        register
            .withUnretained(self)
            .withLatestFrom(combineLatest) { value, flag in
                let vc = value.0
                let (id , password, isCorrect, email, nickname) = flag
                return vc.isValid(id , password, isCorrect, email, nickname)
            }
            .filter{ $0 }
            .subscribe(with: self, onNext: { vc, flag in
                guard let userInfo = vc.makeUserInfo() else { return }
                vc.request( userInfo )
            }).disposed(by: disposeBag)
    }
    
    @inlinable func isValid(_ id: Bool, _ password: Bool, _ isCorrect: Bool, _ email: Bool, _ nickname: Bool) -> Bool {
        if !id {
            self.toast(content: "올바른 아이디를 입력해주세요!")
            return false
        }
        if !password {
            self.toast(content: "올바른 패스워드를 입력해주세요!")
            return false
        }
        if !isCorrect {
            self.toast(content: "패스워드가 일치하지 않습니다!")
            return false
        }
        if !email {
            self.toast(content: "올바른 이메일을 입력해주세요!")
            return false
        }
        if !nickname {
            self.toast(content: "올바른 닉네임을 입력해주세요!")
            return false
        }
        return true
    }
    
    
    
    //MARK: - Send to server register message
    private func request(_ member: MemberDTO) {
        guard let service else { return }
        _ = service.signUp(member: member)
            .subscribe(with: self, onSuccess: { vc, flag in
                flag ? vc.toast(content: "실패하였습니당") : vc.steps.accept(CodestackStep.registerDissmiss)
            })
    }
    
    
    //MARK: - Util 함수
    private func toast(content: String) {
        Toast.toastMessage("\(content)",
                           offset: 60,
                           background: CColor.red.color,
                           boader: UIColor.black.cgColor)
    }
    
    private func makeUserInfo() -> MemberDTO? {
        
        guard let id = idField.text else { return nil }
        guard let password = passwordField.text else { return nil }
        guard let email = emailField.text else { return nil }
        guard let nickname = nickNameField.text else { return nil }
        
        return MemberDTO(id: id, password: password, email: email, nickName: nickname)
    }
    
    private func markColorWhenVaild(type: Valid, view: UIView) {
        switch type {
        case .empty:
            view.layer.borderColor = CColor.whiteGray.cgColor
        case .corret:
            view.layer.borderColor = CColor.green.cgColor
        case .wrong:
            view.layer.borderColor = CColor.red_up.cgColor
        }
    }
    
    private func isValid(pattern: String, text: String, view: UITextField) -> Bool {
        if text.isEmpty {
            markColorWhenVaild(type: .empty, view: view)
            return false
        }
        let valid = self.isValidPattern(pattern: pattern, text: text)
        valid ? markColorWhenVaild(type: .corret, view: view) : markColorWhenVaild(type: .wrong, view: view)
        return valid
    }
    
    private func isValidPattern(pattern: String, text: String) -> Bool {
        if let _ = text.range(of: pattern, options: .regularExpression) {
            return true
        }else{
            return false
        }
    }
}

extension RegisterViewController: UITextFieldDelegate{
    
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
    
    var fields: [UITextField] {
        [
            idField,
            passwordField,
            isCorrectPasswordField,
            emailField,
            nickNameField
        ]
    }
    
    private func remakeScrollViewLayout(value: CGFloat){
        scrollView.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-value)
        }
    }
    
    private func addAutoLayout(){
        
        self.view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(registerButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.height.equalTo(view.snp.height).priority(.low)
        }
        
        let labels = [
            idFieldLabel,
            passwordFieldLabel,
            isCorrectPasswordFieldLabel,
            emailFieldLabel,
            nickNameFieldLabel
        ]
        
        labels.forEach{ subview in
            containerView.addSubview(subview)
            subview.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(32)
            }
        }
        
        fields.forEach { subview in
            containerView.addSubview(subview)
            subview.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(24)
                make.height.equalTo(50)
            }
        }
        
        idFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(28)
        }
        
        zip(labels, fields).forEach { label,fields in
            fields.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom).offset(8)
            }
        }
        
        zip(labels[1..<labels.count], fields).forEach { label, fields in
            label.snp.makeConstraints { make in
                make.top.equalTo(fields.snp.bottom).offset(24)
            }
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(fields.last!.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
        
    }
}



extension UILabel{
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
}
