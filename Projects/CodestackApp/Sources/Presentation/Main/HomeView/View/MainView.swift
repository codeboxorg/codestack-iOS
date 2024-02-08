//
//  MainView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import RxCocoa
import RxSwift
import CommonUI

class MainView: UIView {
    
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
    func emitTodayAndRecommendBtnEvent() -> Signal<ButtonType>{
        let events = [subView_1.buttonTapSignal(),subView_2.buttonTapSignal()]
        return Signal.merge(events).asSignal()
    }

    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    private let imageViewHeight: CGFloat = 300
    private let spacing: CGFloat = 1
    private lazy var subViews_1_height: CGFloat = subView_1.getViewHeight()
    private lazy var subViews_2_height: CGFloat = subView_2.getViewHeight()
    private let introduce_small_offset: CGFloat = 20
    
    lazy var container_height = subViews_1_height + subViews_2_height + 10
    
    func skeletonLayout() {
        subView_1.layoutIfNeeded()
        subView_2.layoutIfNeeded()
        subView_1.subviews.forEach { subView in
            subView.addSkeletonAndRemoveView()
        }
        subView_2.subviews.forEach { subView in
            subView.addSkeletonAndRemoveView()
        }
    }
    
    private func layoutConfigure(){
        self.addSubview(containerView)
        
        containerView.addSubview(subView_1)
        containerView.addSubview(subView_2)
        
        containerView.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(500).priority(.low)
            $0.bottom.equalToSuperview()
        }
        
        subView_1.snp.makeConstraints{
            $0.top.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(subViews_1_height)
        }
        
        subView_2.snp.makeConstraints{
            $0.top.equalTo(subView_1.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            //MARK: - priority low 로 설정해야 오토레이아웃 오류 안남, 이유 -> bottomEqualToSuperView와 height의 충돌 때문에
            $0.height.equalTo(subViews_2_height + spacing).priority(.low)
            $0.bottom.equalToSuperview()
        }
    }
}
