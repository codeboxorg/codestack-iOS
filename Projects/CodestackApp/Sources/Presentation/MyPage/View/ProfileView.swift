//
//  ProfileView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/05/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Global
import Domain
import CommonUI

final class ProfileView: UIView{

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let imageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private(set) var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = UIColor.gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.text = "ParkHyeongHwan"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    
    private let language: UILabel = {
        let label = UILabel()
        label.text = "언어"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }()
    
    private let preferLaguageLabel: UILabel = {
        let label = UILabel()
         label.text = "C"
         label.font = UIFont.boldSystemFont(ofSize: 16)
         label.numberOfLines = 1
        label.textAlignment = .left
         label.minimumScaleFactor = 0.7
         return label
     }()
    
    private(set) var editButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit profile", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
        button.layer.cornerRadius = 12
        return button
    }()
    
    var disposeBag = DisposeBag()
    
    /// Binder   뷰에 프로필 데이터 바인딩
    var profileBinder: Binder<MemberVO> {
        Binder(self){ [weak self] target ,value  in
            guard let self else { return }
            self.nameLabel.text = value.nickName
            self.preferLaguageLabel.text = value.preferLanguage.name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addAutoLayout()
        settingColor()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    enum LoadingState: Equatable {
        case notLoading
        case loading
        case loaded(Data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    func loadingBinding(_ loading: Driver<LoadingState>) {
        loading
            .drive(with: self, onNext: { view, state in
                view.stateAnimating(state: state)
            }).disposed(by: disposeBag)
    }
    
    func stateAnimating(state: LoadingState){
        switch state {
        case .notLoading:
            self.imageView.image = nil
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
        case .loading:
            self.imageView.image = nil
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
        case .loaded(let data):
            // TODO: 이미지 로컬 저장소에 저장해야함
            // TODO: Cache 처리 해야되는데 .....
            self.imageView.load(data: data) { [weak self] _ in
                self?.imageView.stopAnimating()
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
            }
        }
    }
}



//MARK: - ProfileView AutoLayout,
private extension ProfileView {
    
    func settingColor() {
        self.backgroundColor = .tertiarySystemBackground
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
    }
    
    func addAutoLayout() {
        
        [imageContainerView,nameLabel,language,preferLaguageLabel,editButton].forEach {
            self.addSubview($0)
        }
        
        imageContainerView.addSubview(imageView)
        imageContainerView.addSubview(activityIndicator)
        
        imageContainerView.snp.makeConstraints {
            $0.width.height.equalTo(80)
            $0.top.leading.equalToSuperview().inset(16)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(imageContainerView.snp.center)
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.top).offset(12)
            $0.leading.equalTo(imageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        language.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(-25)
            $0.leading.equalTo(nameLabel.snp.leading)
        }
        
        language.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        language.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        preferLaguageLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(-25)
            $0.leading.equalTo(language.snp.trailing).offset(8)
            $0.trailing.equalTo(nameLabel.snp.trailing)
        }
        
        editButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().inset(16).priority(.high)
        }
    }
}
