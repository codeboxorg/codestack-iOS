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
    
    private lazy var popUpContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        return containerView
    }()
    
    private lazy var popUptitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎉 빡코딩 레스토랑 2주년 이벤트 "
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PlaceHolderImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
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
            make.top.equalTo(popUpContainerView.snp.bottom)
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
            make.top.equalToSuperview().priority(.low)
            make.bottom.equalToSuperview()
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
                
                self.imageView.image = UIImage()
            }
        )
    }
}


private extension ProblemPopUpView{
    
    func configure() {
        self.backgroundColor = .tertiarySystemBackground
    }
    
    
    private func autoLayout() {
        self.addSubview(popUpContainerView)
        self.addSubview(hideButton)
        
        [popUptitleLabel,imageView].forEach{
            self.popUpContainerView.addSubview($0)
        }
        
        popUpContainerView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(434).priority(.low) //.priority(.low)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        popUptitleLabel.snp.makeConstraints{
            $0.top.equalToSuperview().inset(29)
            $0.leading.equalToSuperview().inset(16)
        }
        
        imageView.snp.makeConstraints{
            $0.width.equalTo(343)
            $0.height.equalTo(245)
            $0.top.equalTo(popUptitleLabel.snp.bottom)
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
        
        hideButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(popUpContainerView.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(50)
        }
    }
}
