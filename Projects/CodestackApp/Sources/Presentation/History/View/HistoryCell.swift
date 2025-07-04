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
import Global
import Domain

class HistoryCell: UITableViewCell {

    private let boxContainer: UIView = {
       let view = UIView()
        return view
    }()
    
    private let problemName: UILabel = {
        let label = UILabel()
        return label.introduceLable(18, "", style: .title2)
    }()
    
    private lazy var explainLabel: UILabel = {
        let label = UILabel()
        let label2 = label.introduceLable(15, "TestTestTestTestTestTest", style: .body)
        label2.layer.cornerRadius = 4
        label2.textAlignment = .left
        return label2
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        return label.descriptionLabel(text: "임시")
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        let new = label.descriptionLabel(text: "1시간 전")
        new.textColor = UIColor.label
        return new
    }()
    
    private let languageBtn: LanguageButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.titlePadding = 10
        let button = LanguageButton().makeLanguageButton()
        button.configuration = configuration
        button.setTitleColor(.label, for: .normal)
        button.setTitle("   ", for: .normal)
        return button
    }()
    
    var onHistoryData = PublishRelay<SubmissionVO>()
    var onStatus = PublishRelay<SolveStatus>()
    
    var cellDisposeBag = DisposeBag()
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutConfigure()

        Driver.zip(onHistoryData.asDriver(onErrorJustReturn: .sample),
                   onStatus.asDriver(onErrorJustReturn: .none))
        .drive(with: self, onNext: { cell, data in
            let (submission, solveStatus) = data
            cell.statusLabel.pr_status_label(solveStatus, default: false)
            cell.titleBoxContainerSetting(status: solveStatus)
            cell.descriptionSetting(status: solveStatus, problem: submission.problem.title)
            cell.problemName.text = submission.problem.title
            
            /// Skeleton Layer 추가 삭제
            if submission.isMock {
                cell.layoutIfNeeded()
                cell.applySkeletonView(submission.language.name)
            } else {
                cell.languageBtn.setTitle(submission.language.name , for: .normal)
                cell.contentView.removeSkeletonViewFromSuperView {
                    cell.languageBtn.layer.borderColor = UIColor.sky_blue.cgColor
                }
            }
            
            if let date = submission.createdAt.toDateStringUTCORKST(format: .FULL) {
                let dateString = DateCalculator().caluculateTime(date)
                cell.timeLabel.text = dateString
                return
            }
        })
        .disposed(by: cellDisposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    
    private func applySkeletonView(_ languageName: String) {
        let height = "Test".height(withConstrainedWidth: 0, font: explainLabel.font)
        let width = explainLabel.attributedText?.string.width(withConstrainedHeight: height, font: explainLabel.font)
        let prHeight = problemName.text?.height(withConstrainedWidth: 10, font: problemName.font)
        let prWidth = problemName.text?.width(withConstrainedHeight: prHeight ?? 10, font: problemName.font)
        let _prWidth = (prWidth ?? 30) + 20
        let _prHeight = (prHeight ?? 30) + 10
        let btnwidth = "C+++".width(withConstrainedHeight: 30, font: explainLabel.font)
        let tHeight = "10 시간전".height(withConstrainedWidth: 10, font: timeLabel.font)
        let tWidth = "10 시간전".width(withConstrainedHeight: tHeight, font: timeLabel.font)
        languageBtn.layer.borderColor = UIColor.clear.cgColor
        
        explainLabel.addSkeletonView(width: width ?? 0,height: height)
        boxContainer.addSkeletonView(width: _prWidth, height: _prHeight)
        languageBtn.addSkeletonView(width: btnwidth + 30)
        statusLabel.addSkeletonView()
        timeLabel.addSkeletonView(width: tWidth, height: tHeight )
    }
    
    private func layoutConfigure() {
        self.contentView.addSubview(statusLabel)
        self.contentView.addSubview(explainLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(boxContainer)
        self.contentView.addSubview(languageBtn)
        
        boxContainer.addSubview(problemName)
        boxContainer.layer.borderColor =  UIColor.sky_blue.cgColor
        boxContainer.layer.borderWidth = 1
        boxContainer.layer.cornerRadius = 5
        
        boxContainer.snp.makeConstraints{ make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(statusLabel.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview().inset(12)
            make.height.equalTo(30)//.priority(.low)
        }
        
        problemName.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        statusLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        explainLabel.snp.makeConstraints { make in
            make.top.equalTo(boxContainer.snp.bottom).offset(8)
            make.leading.equalTo(statusLabel.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(languageBtn.snp.leading).offset(-8)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-16)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
        }
        
        languageBtn.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(16)
            make.width.equalTo(35).priority(.low)
            make.height.equalTo(35)
        }
    }
}


//MARK: - SolveStatus - Label, View setting
extension HistoryCell{
    private func titleBoxContainerSetting(status: SolveStatus){
        boxContainer.layer.borderColor = status.color.cgColor
    }
    
    private func descriptionSetting(status: SolveStatus, problem name: String){
        let nsMutableString = NSMutableAttributedString()
        
        nsMutableString.append(NSAttributedString(string: " 문제를 "))
        
        let key = NSAttributedString.Key.foregroundColor
        switch status {
        case .favorite:
            nsMutableString.append(NSAttributedString(string: "즐겨찾기",attributes: [key : status.color]))
            nsMutableString.append(NSAttributedString(string: "에 추가하였습니다"))
            explainLabel.attributedText = nsMutableString
            
        case .temp:
            nsMutableString.append(NSAttributedString(string: "임시저장",attributes: [key : status.color]))
            nsMutableString.append(NSAttributedString(string: " 중입니다"))
            explainLabel.attributedText = nsMutableString
            
        case .AC:
            nsMutableString.append(NSAttributedString(string: "성공",attributes: [key : status.color]))
            nsMutableString.append(NSAttributedString(string: " 하셨습니다"))
            explainLabel.attributedText = nsMutableString
            
        case .MLE,.OLE,.PE,.RE,.TLE, .WA:
            nsMutableString.append(NSAttributedString(string: "실패",attributes: [key : status.color]))
            nsMutableString.append(NSAttributedString(string: " 하였습니다"))
            explainLabel.attributedText = nsMutableString
        default:
            break
        }
    }
}
