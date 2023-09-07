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

class ProfileView: UIView{
    
    
    struct Profile {
        let imageURL: String?
        let name: String
        let rank: String?
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = UIColor.gray
        imageView.layer.cornerRadius = 12
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 0.1
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
    
    
    private let rank: UILabel = {
        let label = UILabel()
        label.text = "Rank"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
         label.text = "120"
         label.font = UIFont.boldSystemFont(ofSize: 16)
         label.numberOfLines = 1
        label.textAlignment = .left
         label.minimumScaleFactor = 0.7
         return label
     }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit profile", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
        button.layer.cornerRadius = 12
        return button
    }()
    
    /// Binder   뷰에 프로필 데이터 바인딩
    var profileBinder: Binder<Profile> {
        Binder(self){ [weak self] target ,value  in
            guard let self else { return }
            
            self.nameLabel.text = value.name
            self.rank.text = value.rank
            
            if let imageURL = value.imageURL,
            let url = URL(string: imageURL) {
                self.imageView.load(url: url)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addAutoLayout()
        settingColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
    func editProfileEvent() -> Signal<Void> {
        editButton.rx.tap.asSignal()
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
        
        [imageView,nameLabel,rank,rankLabel,editButton].forEach {
            self.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(80)
            $0.top.leading.equalToSuperview().inset(16)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.top).offset(12)
            $0.leading.equalTo(imageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        rank.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(-25)
            $0.leading.equalTo(nameLabel.snp.leading)
        }
        rank.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        rank.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        rankLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(-25)
            $0.leading.equalTo(rank.snp.trailing).offset(8)
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

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
