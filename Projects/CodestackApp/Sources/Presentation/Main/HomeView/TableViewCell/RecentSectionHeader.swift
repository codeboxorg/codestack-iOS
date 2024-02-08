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
        return label.descriptionLabel(size: 14, text: "", color: UIColor.label)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addAutoLayout()
    }
    
    func settingHeader(_ text: String ){
        self.label.text = "\(text) 🔥"
    }
    
    private func addAutoLayout(){
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 12),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
}
