//
//  CollectionViewCell.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/30.
//


import Foundation
import UIKit
import SnapKit

class OnBoardingCell: UICollectionViewCell{
    
    let firstContent: String = "Managing your\ncoding has never been so easy."
    let secondContent: String = "Spend smarter every day. all from one app."
    
    private lazy var titleContent: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.07, green: 0.202, blue: 0.542, alpha: 1)
        label.font = UIFont(name: "NanumGothicExtraBold", size: 34)
        label.lineBreakMode = .byWordWrapping
        var pargraphStyle = NSMutableParagraphStyle()
        pargraphStyle.lineHeightMultiple = 1.05
        label.attributedText = NSMutableAttributedString(string: firstContent, attributes: [NSAttributedString.Key.kern : 0.2, NSAttributedString.Key.paragraphStyle : pargraphStyle])
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let codestackLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sky_blue
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.text = "Codestack"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .systemGray6
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(codestackLabel)
        
        imageView.snp.makeConstraints{
            $0.center.equalToSuperview()
            $0.width.height.equalTo(85)
        }
        
        codestackLabel.snp.makeConstraints{
            $0.top.equalTo(imageView.snp.bottom).offset(15)
            $0.centerX.equalTo(imageView.snp.centerX)
        }
    }
    
    func updataUI(_ image: UIImage) {
        imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fattal error")
    }
    
}


