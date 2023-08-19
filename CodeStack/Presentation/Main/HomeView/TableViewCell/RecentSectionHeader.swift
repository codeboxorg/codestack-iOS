//
//  EmptyCell.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/19.
//

import UIKit



class RecentSectionHeader: UICollectionReusableView{
    
    let label: UILabel = {
        let label = UILabel()
        return label.descriptionLabel(size: 16, text: "", color: UIColor.lightGray)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addAutoLayout()
    }
    
    func addAutoLayout(){
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
}
