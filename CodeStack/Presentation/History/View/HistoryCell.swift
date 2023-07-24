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

    
    private let boxContainer: UIView = {
       let view = UIView()
        return view
    }()
    
    private let problemName: UILabel = {
        let label = UILabel()
        return label.introduceLable(18, "", style: .title2)
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        let label2 = label.introduceLable(14, "", style: .body)
        label2.textAlignment = .left
        return label2
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

        Driver.zip(onHistoryData.asDriver(onErrorJustReturn: .init(_problem: _Problem(title: "error"))),
                   onStatus.asDriver(onErrorJustReturn: .none))
        .drive(with: self,onNext: { cell, data in
            let (submission, solveStatus) = data
            cell.statusLabel.pr_status_label(solveStatus, default: false)
            cell.titleLabelSetting(status: solveStatus, problem: submission.problem?.title ?? "hellow world ")
            cell.problemName.text = submission.problem?.title
        })
        .disposed(by: disposeBag)
    }
    
    func titleLabelSetting(status: SolveStatus, problem name: String){
        let nsMutableString = NSMutableAttributedString()
        
        nsMutableString.append(NSAttributedString(string: " 문제를 "))
        
        let key = NSAttributedString.Key.foregroundColor
        switch status {
        case .favorite:
            boxContainer.layer.borderColor = UIColor.systemYellow.cgColor
            nsMutableString.append(NSAttributedString(string: "즐겨찾기",attributes: [key : UIColor.systemYellow]))
            nsMutableString.append(NSAttributedString(string: "에 추가하였습니다"))
            titleLabel.attributedText = nsMutableString
        case .temp:
            boxContainer.layer.borderColor = UIColor.systemGray.cgColor
            nsMutableString.append(NSAttributedString(string: "임시저장",attributes: [key : UIColor.systemGray]))
            nsMutableString.append(NSAttributedString(string: " 중입니다"))
            titleLabel.attributedText = nsMutableString
        case .solve:
            boxContainer.layer.borderColor = UIColor.systemGreen.cgColor
            nsMutableString.append(NSAttributedString(string: "성공",attributes: [key : UIColor.systemGreen]))
            nsMutableString.append(NSAttributedString(string: " 하셨습니다"))
            titleLabel.attributedText = nsMutableString
        case .fail:
            boxContainer.layer.borderColor = UIColor.systemRed.cgColor
            nsMutableString.append(NSAttributedString(string: "실패",attributes: [key : UIColor.systemRed]))
            nsMutableString.append(NSAttributedString(string: " 하였습니다"))
            titleLabel.attributedText = nsMutableString
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    
    private func layoutConfigure() {
        
        
        self.contentView.addSubview(statusLabel)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(boxContainer)
        
        boxContainer.addSubview(problemName)
        
//        boxContainer.backgroundColor = UIColor.sky_blue
        
        boxContainer.layer.borderColor =  UIColor.sky_blue.cgColor
        boxContainer.layer.borderWidth = 1
        
        boxContainer.layer.cornerRadius = 5
        
        boxContainer.snp.makeConstraints{ make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(statusLabel.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview().inset(12)
            make.height.equalTo(30).priority(.low)
        }
        
        
        problemName.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        statusLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(boxContainer.snp.bottom).offset(8)
            make.leading.equalTo(statusLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(8).priority(.low)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel.snp.leading)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-12)
        }
        
    }
}
