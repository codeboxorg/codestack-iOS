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
        return label.descriptionLabel(text: "")
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        return label.descriptionLabel(text: "")
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        return label.descriptionLabel(text: "1시간 전")
    }()
    
    var onHistoryData = PublishRelay<Submission>()
    var onStatus = PublishRelay<SolveStatus>()
    
    var cellDisposeBag = DisposeBag()
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutConfigure()
        
        onHistoryData
            .asDriver(onErrorJustReturn: .init(_problem: _Problem(title: "error")))
            .drive(with: self,onNext: { cell, submission in
                let status = SolveStatus.allCases.randomElement()!
                cell.statusLabel.pr_status_label(status, default: false)
                cell.titleLabelSetting(status: status, problem: submission.problem?.title ?? "Hello world")
            }).disposed(by: disposeBag)
    }
    
    func titleLabelSetting(status: SolveStatus, problem name: String){
        switch status {
        case .favorite:
            titleLabel.text = name + " 문제를 즐겨찾기에 추가하였습니다"
        case .temp:
            titleLabel.text = name + " 문제를 임시저장 중입니다"
        case .solve:
            titleLabel.text = name + " 문제를 성공 하셨습니다"
        case .fail:
            titleLabel.text = name + " 문제를 실패 하였습니다"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    
    private func layoutConfigure() {
        self.contentView.layer.borderColor = UIColor.sky_blue.cgColor
        self.contentView.layer.borderWidth = 1
        
        self.contentView.addSubview(statusLabel)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(timeLabel)
        
        statusLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(statusLabel.snp.trailing).offset(12)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel.snp.leading)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-12)
        }
        
    }
}
