//
//  ProfileView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/05/23.
//

import UIKit
import SnapKit

class ProfileView: UIView{
    
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = UIColor.yellow
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
    func addAutoLayout(){
        self.addSubview(imageView)
        
        imageView.snp.makeConstraints{
            $0.width.height.equalTo(50)
            $0.top.equalToSuperview().inset(40)
        }
    }
    
    
    
    
}

