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
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .systemGray6
        self.contentView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updataUI(_ image: UIImage) {
        imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fattal error")
    }
    
}


