//
//  PageCell.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/03.
//


import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Domain
import Global

final class PRSubmissionHistoryCell: UICollectionViewCell {

    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        return label
    }()
    
    private let contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "list.clipboard.fill")
        imageView.contentMode = .scaleToFill
        imageView.tintColor = UIColor.sky_blue
        // LAYER 계층을 위로 올린다
        imageView.layer.zPosition = 1
        return imageView
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .left
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        return label.descriptionLabel(size: 13, text: "", color: .systemGray)
    }()
    
    
    var onRecentPageData = PublishRelay<SubmissionVO>()
    var onStatus = PublishRelay<SolveStatus>()
    
    var cellDisposeBag = DisposeBag()
    var disposeBag = DisposeBag()
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        addAutoLayout()
        
        onRecentPageData
            .asDriver(onErrorJustReturn: .sample)
            .drive(onNext: {[weak self] submission in
                guard let self = self else {return}
                self.titleLabel.text = submission.problem.title
                
                if let solvedDate = submission.createdAt.toDateStringKST(format: .FULL){
                    let dateString = DateCalculator().caluculateTime(solvedDate)
                    self.dateLabel.text = dateString
                }
                
            }).disposed(by: cellDisposeBag)
        
        onStatus
            .asDriver(onErrorJustReturn: .none)
            .drive(onNext: { [weak self] status in
                guard let self = self else {return}
                self.statusLabel.pr_status_label(status)
            }).disposed(by: cellDisposeBag)
    }
    
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let layer = CAShapeLayer()
        
        let path = UIBezierPath()
        let yPoint = rect.size.height * 2 / 3
        path.move(to: CGPoint(x: .zero, y: yPoint))
        path.addLine(to: CGPoint(x: rect.size.width, y: yPoint))

        layer.path = path.cgPath
        layer.strokeColor = UIColor.lightGray.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 3
        
        contentView.layer.addSublayer(layer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    @objc func dopinch(_ pinch: UIPinchGestureRecognizer){
        contentImageView.transform = contentImageView.transform.scaledBy(x: pinch.scale, y: pinch.scale)
        pinch.scale = 1
    }
    
    func addAutoLayout() {
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(dopinch(_:)))
        self.contentView.addGestureRecognizer(pinch)
        
        self.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.systemBackground
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.label.cgColor
        contentView.layer.cornerRadius = 10
        
        
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(statusLabel)
        self.contentView.addSubview(contentImageView)
        self.contentView.addSubview(dateLabel)
        
        statusLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(-4)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(10)
        }
        
        titleLabel.snp.makeConstraints{
            $0.top.equalTo(statusLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(5)
        }
        
        contentImageView.snp.makeConstraints{
            $0.centerY.equalToSuperview().offset(25)
            $0.leading.equalToSuperview().inset(12)
            $0.width.height.equalTo(50)
        }
        
        dateLabel.snp.makeConstraints{
            $0.bottom.trailing.equalToSuperview().inset(10)
        }
    }
    
}

