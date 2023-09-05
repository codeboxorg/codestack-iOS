




import UIKit
import SnapKit

class RegisterViewController: UIViewController{
    
    private let idField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "아이디를 입력해주세요"
        textField.borderStyle = .line
        return textField
    }()
    
    private let idFieldLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        
        return textField
    }()
    
    private let passwordFieldLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let isCorrectPasswordField: UITextField = {
        let textField = UITextField()
        
        return textField
    }()
    
    private let isCorrectPasswordFieldLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let emailField: UITextField = {
        let textField = UITextField()
        
        return textField
    }()
    
    
    private let emailFieldLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let nickNameField: UITextField = {
        let textField = UITextField()
        
        return textField
    }()
    
    
    private let nickNameFieldLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func addAutoLayout(){
        
        [idField].forEach { subview in
            view.addSubview(subview)
        }
        
        idField.snp
    }
}
