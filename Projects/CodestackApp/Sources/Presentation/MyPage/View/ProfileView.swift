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

class ProfileView: UIView{

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let imageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let imageView: UIImageView = {
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
    
    var disposeBag = DisposeBag()
    
    /// Binder   뷰에 프로필 데이터 바인딩
    var profileBinder: Binder<MemberVO> {
        Binder(self){ [weak self] target ,value  in
            guard let self else { return }
            
            self.nameLabel.text = value.username // ?? "Unknown"
            
            // TODO: Rank 어떻게 해야돼ㅣㅁ?
            self.rank.text = "N/A"
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
        case loaded(String?)
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
            Log.debug("notLoading")
            self.imageView.image = nil
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
        case .loading:
            Log.debug("loading")
            self.imageView.image = nil
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
        case .loaded(let urlstring):
            Log.debug("loaded")
            if urlstring == nil {
                self.imageView.image = UIImage(named: "codeStack")
            } else {
                //TODO: 이미지 로컬 저장소에 저장해야함
                //TODO: Cache 처리 해야되는데 .....
                if let urlstring,
                   let url = URL(string: urlstring) {
                    self.imageView.load(url: url, completion: { [weak self] _ in
                        self?.imageView.stopAnimating()
                        self?.activityIndicator.isHidden = true
                    })
                }
            }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    func editProfileEvent() -> Signal<Void> {
        editButton.rx.tap.share().asSignal(onErrorJustReturn: ())
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
        
        [imageContainerView,nameLabel,rank,rankLabel,editButton].forEach {
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
    
    func load(url: URL, completion: @escaping (UIImage) -> () ) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            if let data = try? Data(contentsOf: url) {
                self.load(data: data, completion: completion)
            }
        }
    }
    
    func load(data: Data, completion: @escaping (UIImage) -> ()) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.image = image
                completion(image)
            }
        }
    }
    
}
