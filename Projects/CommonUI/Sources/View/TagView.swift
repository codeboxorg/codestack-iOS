//
//  LangugeView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/17.
//

import UIKit
import SnapKit

public final class TagView: UIView {

    private let widthSpacing: CGFloat = 20
    private let heightSpacing: CGFloat = 20
    
    static var labelSize: CGFloat = 12
    
    public lazy var featureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: TagView.labelSize)
        return label
    }()
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return featureLabel.sizeThatFits(size) // New
    }
    
    public func getItemWidh() -> CGFloat {
        return sizeThatFits(CGSize()).width + widthSpacing
    }
    
    public func getItemHeight() -> CGFloat  {
        return sizeThatFits(CGSize()).height + heightSpacing
    }
    
    public func setText(text: String) {
        featureLabel.text = text
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
       
        self.addSubview(featureLabel)
        featureLabel.snp.makeConstraints{
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    public convenience init(frame: CGRect,
                     corner radius: CGFloat,
                     background color: UIColor,
                     text color_t: UIColor) {
        self.init(frame: frame)
        self.backgroundColor = color
        self.layer.cornerRadius = radius
        self.featureLabel.textColor = color_t
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
}
