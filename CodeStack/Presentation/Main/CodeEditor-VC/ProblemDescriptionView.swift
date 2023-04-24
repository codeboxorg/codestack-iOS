//
//  ProblemDescriptionView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/23.
//

import UIKit
import SnapKit



final class ProblemPopUpView: UIView{
    
    var popUpFlag: Bool = false
    
    private lazy var scrollView: CustomScrollView = {
        let scrollView = CustomScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private lazy var popUpContainerView: UIView = {
        let containerView = UIView()
        return containerView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = UIColor.systemGray
        button.addTarget(self, action: #selector(backKeyPressed(_:)), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    @objc func backKeyPressed(_ sender: UIButton){
        if let delegate {
            delegate.navigationController?.popViewController(animated: true)
        }
    }
    
    
    private lazy var problemName_label: UILabel = {
        let label = UILabel()
        label.text = "Hellow World!"
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private lazy var separatorLine_top: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray
        return view
    }()
    
    private lazy var problem_label: UILabel = {
        let label = UILabel()
        label.text = "문제 설명"
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private lazy var problem_문제_description: UILabel = {
        let label = UILabel()
        label.text = "문자열 str 이 주어질 때, str을 출력하는 코드를 작성해 보세요."
        label.numberOfLines = 0
        label.textColor = UIColor.systemGray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray
        return view
    }()
    
    private lazy var limit_label: UILabel = {
        let label = UILabel()
        label.text = "제한 사항"
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private lazy var separatorLine2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray
        return view
    }()
    
    private lazy var limit_제한사항: UILabel = {
        let label = UILabel()
        label.text = "1 <= str의 길이 <= 1,000,000\n str에는 공백이 없으며, 첫째 줄에 한 줄로만 주어집니다."
        label.textColor = UIColor.systemGray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private lazy var inOut_입출력예_label: UILabel = {
        let label = UILabel()
        label.text = "입출력 예"
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private lazy var input_label: UILabel = {
        let label = UILabel()
        label.text = "입력 #1"
        label.textColor = UIColor.systemGray
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private lazy var inputTextField: InsetTextField = {
        let field = InsetTextField(frame: .zero)
        field.text = "Hellow World!"
        return field
    }()
    
    private lazy var output_label: UILabel = {
        let label = UILabel()
        label.text = "출력 #1"
        label.textColor = UIColor.systemGray
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private lazy var outputTextField: InsetTextField = {
        let field = InsetTextField(frame: .zero)
        field.text = "Hellow World!"
        return field
    }()
    
    
    private lazy var hideButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(hidebuttonTapped(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.backgroundColor = UIColor.black
        button.tintColor = UIColor.systemPink
        button.layer.cornerRadius = 25
        return button
    }()
    
    private lazy var sideButton: UIButton = {
       let view = UIButton()
        return view
    }()
    
    private weak var delegate: CodeEditorViewController?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        autoLayout()
    }
    
    convenience init(frame: CGRect, _ delegate: CodeEditorViewController) {
        self.init(frame: frame)
        self.delegate = delegate
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError occur!")
    }
    
    deinit{
        print("deinit")
    }
    
    @objc func hidebuttonTapped(_ sender: UIButton){
        popUpFlag == true ? show() : hide(completion: nil)
        popUpFlag.toggle()
    }
    
    func show(){
        hideButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        self.delegate!.showProblemDiscription()
        
        hideButton.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.popUpContainerView.backgroundColor = .tertiarySystemBackground
                
                self.popUpContainerView.alpha = 1
                self.delegate!.view.layoutIfNeeded()
                self.layoutIfNeeded()
                self.popUpContainerView.layoutIfNeeded()
            },
            completion: { _ in
            }
        )
    }
    
    func hide(completion: (() -> Void)? ) {
        hideButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        
        
        self.delegate!.dismissProblemDiscription()
        
        hideButton.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.popUpContainerView.alpha = 0
                self.delegate!.view.layoutIfNeeded()
            },
            completion: { flag in
                if flag == true,
                   completion != nil{
                    completion!()
                }
            }
        )
    }
}


private extension ProblemPopUpView{
    
    func configure() {
        self.backgroundColor = .tertiarySystemBackground
    }
    
    private func autoLayout() {
        self.addSubview(scrollView)
        self.addSubview(hideButton)
        scrollView.addSubview(popUpContainerView)
        
        [backButton,
         problemName_label,
         separatorLine_top,
         problem_label,
         problem_문제_description,
         separatorLine,
         limit_label,
         limit_제한사항,
         separatorLine2,
        inOut_입출력예_label,
        input_label,
         inputTextField,
        output_label,
        outputTextField].forEach{
            popUpContainerView.addSubview($0)
        }
        
        let button_width_height: CGFloat = 50
        
        let vertical_spacing: CGFloat = 25
        
        let leading_trailing_spacing: CGFloat = 20
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(button_width_height)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalToSuperview().inset(vertical_spacing)
            make.width.height.equalTo(44)
        }
        
        hideButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.height.equalTo(button_width_height).priority(.high)
        }
            
        popUpContainerView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(434).priority(.low) //.priority(.low)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        problemName_label.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(leading_trailing_spacing)
            make.leading.equalTo(backButton.snp.trailing).offset(leading_trailing_spacing)
            make.centerY.equalTo(backButton.snp.centerY)
        }
        
        separatorLine_top.snp.makeConstraints { make in
            make.top.equalTo(problemName_label.snp.bottom).offset(vertical_spacing)
            make.width.equalTo(self.popUpContainerView.snp.width).offset(-leading_trailing_spacing * 2)
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(leading_trailing_spacing)
        }
        
        problem_label.snp.makeConstraints { make in
            make.top.equalTo(separatorLine_top.snp.bottom).offset(vertical_spacing * 2)
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
        }
        
        problem_문제_description.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalTo(problem_label.snp.bottom).offset(vertical_spacing)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.width.equalTo(self.popUpContainerView.snp.width).offset(-leading_trailing_spacing * 2)
            make.height.equalTo(1)
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalTo(problem_문제_description.snp.bottom).offset(vertical_spacing)
        }
        
        limit_label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalTo(separatorLine.snp.bottom).offset(vertical_spacing)
        }
        
        limit_제한사항.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalTo(limit_label.snp.bottom).offset(vertical_spacing)
        }
        
        separatorLine2.snp.makeConstraints { make in
            make.width.equalTo(self.popUpContainerView.snp.width).offset(-leading_trailing_spacing * 2)
            make.height.equalTo(1)
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalTo(limit_제한사항.snp.bottom).offset(vertical_spacing)
        }
        
        inOut_입출력예_label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalTo(separatorLine2.snp.bottom).offset(vertical_spacing)
        }
        
        input_label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalTo(inOut_입출력예_label.snp.bottom).offset(vertical_spacing)
        }
        
        inputTextField.snp.makeConstraints { make in
            make.top.equalTo(input_label.snp.bottom).offset(vertical_spacing)
            make.leading.trailing.equalToSuperview().inset(leading_trailing_spacing)
        }
        
        output_label.snp.makeConstraints { make in
            make.top.equalTo(inputTextField.snp.bottom).offset(vertical_spacing)
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
        }
        
        outputTextField.snp.makeConstraints { make in
            make.top.equalTo(output_label.snp.bottom).offset(vertical_spacing)
            make.leading.trailing.equalToSuperview().inset(leading_trailing_spacing)
            make.bottom.equalToSuperview().inset(leading_trailing_spacing)
        }
        
        
    }
}
