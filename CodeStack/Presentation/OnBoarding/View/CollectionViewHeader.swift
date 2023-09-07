//
//  CollectionViewHeader.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/30.
//

import Foundation
import UIKit
import SnapKit

class OnBoardingHeader: UICollectionReusableView{
    
    let firstContent: String = "Managing your\ncoding has never been so easy."
    
    
    private lazy var title: UILabel = {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .green
        self.snp.makeConstraints{
            $0.height.equalTo(150)
        }
        self.addSubview(title)
        
        title.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.trailing.leading.equalToSuperview()
            
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init ERROR")
    }
}

