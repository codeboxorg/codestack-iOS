//
//  LangugeView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/17.
//

import UIKit



class LanguageTag: UIView {

    private let widthSpacing: CGFloat = 24
    private let heightSpacing: CGFloat = 20
    
     lazy var featureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .systemGray
        return label
    }()
    
    func setText(text: String) {
        featureLabel.text = text
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return featureLabel.sizeThatFits(size) // New
    }
    
    func getItemWidh() -> CGFloat {
        return sizeThatFits(CGSize()).width + widthSpacing
    }
    
    func getItemHeight() -> CGFloat  {
        return sizeThatFits(CGSize()).height + heightSpacing
    }
    
    override func layoutSubviews() {
           super.layoutSubviews()
           invalidateIntrinsicContentSize()
       }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        asdfafds
        self.backgroundColor = .systemCyan
        self.layer.cornerRadius = 8
        
        self.addSubview(featureLabel)
    
        featureLabel.snp.makeConstraints{
            $0.centerX.centerY.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
}
