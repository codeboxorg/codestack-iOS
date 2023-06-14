//
//  MainView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import RxCocoa
import RxSwift

class MainView: UIView{
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var backgroundView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "main-banner")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var introduce_big: UILabel = {
        let label = UILabel()
        return label.introduceLable(30, "다 함께 성장하는\n 코딩테스트 연습 플랫폼")
    }()
    
    private lazy var introduce_small: UILabel = {
        let label = UILabel()
        
        return label.introduceLable(14, "codeStack과 함께 목표를 설정하고 같이 문제를 풀어나가보아요!")
    }()
    
    private let subView_1: TwoLabelOneButton = {
        let view = TwoLabelOneButton(frame: .zero, labelBtnText: .init(headLine: "오늘의 문제 보러가기",
                                                                       description: "오늘도 같이 문제 해결하러 가볼까요?",
                                                                       btn_title: "오늘의 문제"))
        return view
    }()
    
    private let subView_2: TwoLabelOneButton = {
        let view = TwoLabelOneButton(frame: .zero, labelBtnText: .init(headLine: "문제 추천 설정하기",
                                                                       description: "추천받을 문제 난이도와 유형을 선택해 주세요!",
                                                                       btn_title: "문제 추천 받으러 가기"))
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutConfigure()
    }
    
    //MARK: -delegate convenience init
    convenience init(frame: CGRect, stepType: [CodestackStep]) {
        self.init(frame: frame)
        subView_1.buttonType = .today_problem(stepType[safe: 0])
        subView_2.buttonType = .recommand_problem(stepType[safe: 1])
    }
    
    //MARK: - Events merge to Signal
    func emitButtonEvents() -> Signal<ButtonType>{
        let events = [subView_1.buttonTapSignal(),subView_2.buttonTapSignal()]
        return Signal.merge(events).asSignal()
    }
    
#if DEBUG
    func move(){
//        subView_1.today_problem_btn.sendActions(for: .touchUpInside)
    }
#endif
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    private func layoutConfigure(){
        self.addSubview(scrollView)
        
        scrollView.addSubview(containerView)
        containerView.addSubview(backgroundView)
        
        backgroundView.addSubview(introduce_big)
        backgroundView.addSubview(introduce_small)
        
        containerView.addSubview(subView_1)
        containerView.addSubview(subView_2)
        
        scrollView.snp.makeConstraints{
            $0.edges.equalTo(self.snp.edges)
        }
        
        containerView.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview()
            $0.width.equalTo(self.snp.width)
            $0.height.equalTo(500).priority(.low)
            $0.bottom.equalTo(scrollView.snp.bottom)
        }
        
        backgroundView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        introduce_big.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        introduce_small.snp.makeConstraints{
            $0.top.equalTo(introduce_big.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        
        subView_1.snp.makeConstraints{
            $0.top.equalTo(backgroundView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(subView_1.getViewHeight())
        }
        
    
        let spacing: CGFloat = 1
        
        subView_2.snp.makeConstraints{
            $0.top.equalTo(subView_1.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(subView_2.getViewHeight() + spacing)
            $0.bottom.equalToSuperview()
        }
    }
}
