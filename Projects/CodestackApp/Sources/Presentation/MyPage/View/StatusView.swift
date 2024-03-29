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
        view.tintColor = .systemGreen
        view.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        return view
    }()
    
    private let statusViewMedium: ProgressView = {
        let view = ProgressView(progressViewStyle: .bar)
        view.tintColor = .systemYellow
        view.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
        return view
    }()
    
    private let statusViewHard: ProgressView = {
        let view = ProgressView(progressViewStyle: .bar)
        view.tintColor = .systemRed
        view.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        return view
    }()
    
    private lazy var solvedAllCount: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = .powder_blue
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutConfigure()
        circleProgressView.backgroundColor = .systemBackground
        circleProgressView.progressColor = .juhwang
        circleProgressView.progressBackgroundColor = .gray
        circleProgressView.progressWidth = 8
        circleProgressView.progress = 0.5
        circleProgressView.clockwise = false
    }
    
    
    func settingProgressViewAnimation(_ easy: Float,
                                      _ medium: Float,
                                      _ hard: Float){
        self.statusViewEasy.setProgress(easy, animated: true)
        self.statusViewMedium.setProgress(medium, animated: true)
        self.statusViewHard.setProgress(hard, animated: true)
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
        
        circleProgressView.addSubview(solvedAllCount)
        
        
        titleLabel.snp.makeConstraints{
            $0.top.equalToSuperview().inset(12)
            $0.trailing.leading.equalToSuperview().inset(12)
        }
        
        circleProgressView.snp.makeConstraints{
            $0.width.height.equalTo(circleWidthHeight)
            $0.centerY.equalTo(statusViewMedium.snp.centerY)
            $0.leading.equalToSuperview().inset(12)
        }
        
        solvedAllCount.snp.makeConstraints{
            $0.center.equalTo(circleProgressView.snp.center)
            $0.leading.trailing.equalToSuperview().inset(12)
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
