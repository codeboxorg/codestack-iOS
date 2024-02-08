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
import CommonUI

final class PRSubmissionHistoryCell: UICollectionViewCell {

    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.layer.cornerRadius = 6
        label.textColor = .label
        return label
    }()
    
    let contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.tintColor = UIColor.sky_blue
        // LAYER 계층을 위로 올린다
        imageView.layer.zPosition = 1
        return imageView
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .left
        label.layer.cornerRadius = 4
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 4
        return label.descriptionLabel(size: 13, text: "", color: .systemGray)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addAutoLayout()
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
        contentView.backgroundColor = dynamicBackground()
        contentView.layer.cornerRadius = 10
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(statusLabel)
        self.contentView.addSubview(contentImageView)
        self.contentView.addSubview(dateLabel)
        
        statusLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(10)
        }
        
        titleLabel.snp.makeConstraints{
            $0.top.equalTo(statusLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(6)
            $0.trailing.lessThanOrEqualToSuperview().inset(6)
        }
        
        contentImageView.snp.makeConstraints{
            $0.centerY.equalToSuperview().offset(25)
            $0.leading.equalToSuperview().inset(12)
            $0.width.height.equalTo(35)
        }
        
        dateLabel.snp.makeConstraints{
            $0.bottom.trailing.equalToSuperview().inset(10)
        }
    }
    
}

