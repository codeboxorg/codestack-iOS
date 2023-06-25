//
//  StatusView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/25.
//

import UIKit
import SnapKit


class StatusView: UIView{
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Solved Problems"
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }()

    
     let circleProgressView: CircleProgressView = {
        let view = CircleProgressView()
        view.progress = 0.3
        return view
    }()
    
    private let statusViewEasy: ProgressView = {
        let view = ProgressView(progressViewStyle: .bar)
        view.progress = 0.65
        view.tintColor = .systemGreen
        view.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        return view
    }()
    
    private let statusViewMedium: ProgressView = {
        let view = ProgressView(progressViewStyle: .bar)
        view.progress = 0.8
        view.tintColor = .systemYellow
        view.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
        return view
    }()
    
    private let statusViewHard: ProgressView = {
        let view = ProgressView(progressViewStyle: .bar)
        view.progress = 0.93
        view.tintColor = .systemRed
        view.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutConfigure()
        self.backgroundColor = .tertiarySystemBackground
        
        circleProgressView.progressColor = .yellow
        circleProgressView.progressBackgroundColor = .blue.withAlphaComponent(0.5)
        circleProgressView.progressWidth = 8
        circleProgressView.progress = 0.5
        circleProgressView.clockwise = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
    private func layoutConfigure() {
        
        let statusBarSpacingTop: CGFloat = 35
        let circleWidthHeight: CGFloat = 100
        
        let bottomInsetFromSuperView: CGFloat = 30
        [titleLabel,
         circleProgressView,
         statusViewEasy,
         statusViewMedium,
         statusViewHard].forEach{
            self.addSubview($0)
        }
        
        
        titleLabel.snp.makeConstraints{
            $0.top.equalToSuperview().inset(12)
            $0.trailing.leading.equalToSuperview().inset(12)
        }
        
        circleProgressView.snp.makeConstraints{
            $0.width.height.equalTo(circleWidthHeight)
            $0.centerY.equalTo(statusViewMedium.snp.centerY)
            $0.leading.equalToSuperview().inset(12)
        }
        
        statusViewEasy.snp.makeConstraints{
            $0.top.equalTo(statusBarSpacingTop + 12)
            $0.leading.equalTo(circleProgressView.snp.trailing).offset(20)
            $0.height.equalTo(10)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        statusViewMedium.snp.makeConstraints{
            $0.top.equalTo(statusViewEasy.snp.bottom).offset(statusBarSpacingTop)
            $0.leading.equalTo(circleProgressView.snp.trailing).offset(20)
            $0.height.equalTo(10)
            $0.trailing.equalToSuperview().inset(20)
        }
        statusViewHard.snp.makeConstraints{
            $0.top.equalTo(statusViewMedium.snp.bottom).offset(statusBarSpacingTop)
            $0.leading.equalTo(circleProgressView.snp.trailing).offset(20)
            $0.height.equalTo(10)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-bottomInsetFromSuperView)
        }
    }
    
}
