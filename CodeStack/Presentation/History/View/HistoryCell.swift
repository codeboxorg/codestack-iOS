//
//  HistoryCell.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/19.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class HistoryCell: UITableViewCell{

    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .label
        label.text = "안녕하세요 히스토리 테스트 라벨입니다."
        return label
    }()
    
    
    var publishRelay = PublishRelay<String>()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutConfigure()
        
        publishRelay
            .asDriver(onErrorJustReturn: "")
            .drive(with: self,onNext: { cell, str in
                cell.titleLabel.text = str
            }).disposed(by: disposeBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    
    private func layoutConfigure() {
        self.contentView.layer.borderColor = UIColor.sky_blue.cgColor
        self.contentView.layer.borderWidth = 1
        
        self.contentView.addSubview(titleLabel)
        
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.center.equalToSuperview()
        }
    }
}
