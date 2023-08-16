//
//  PagingTableView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import UIKit
import RxSwift
import RxCocoa

class ReusltStatusView: UIView{
    
    
    lazy var status = Binder<Submission>(self)
    { target, submission in
        
        target.problemID.text = submission.id
        target.problemName.text = submission.problem?.title
        target.member.text = submission.member?.nickname ?? submission.member?.username
        target.memoryUsage.text = "\(submission.memoryUsage ?? -1)"
        target.cpuTime.text = "\(submission.cpuTime ?? -1)"
        target.statuscode.text = "\(submission.statusCode ?? "N/A")"

    }
    
    private lazy var V_stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var H_stackViews: [UIStackView] = {
        return (0..<6).map{ _ in
            let stackView = UIStackView()
            stackView.alignment = .center
            stackView.distribution = .equalSpacing
            stackView.spacing = 10
            stackView.axis = .horizontal
            return stackView
        }
    }()
    
    private static let font
    =
    UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline),
           size: 16)
    
    lazy var maxWidth = maxString.width(withConstrainedHeight: 0, font: ReusltStatusView.font) + 40
    lazy var maxHeight = maxString.height(withConstrainedWidth: 0, font: ReusltStatusView.font) + 10
    private let maxString = "메모리 사용"
    
    private let problemID: BoxContainerLabel = {
        let label = BoxContainerLabel()
        return label
    }()
    
    private let problemName: BoxContainerLabel = {
        let label = BoxContainerLabel()
        return label
    }()
    
    private let member: BoxContainerLabel = {
        let label = BoxContainerLabel()
        return label
    }()
    
    private let memoryUsage: BoxContainerLabel = {
        let label = BoxContainerLabel()
        return label
    }()
    
    private let cpuTime: BoxContainerLabel = {
        let label = BoxContainerLabel()
        return label
    }()
    
    private let statuscode: BoxContainerLabel = {
        let label = BoxContainerLabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    private func addAutoLayout(){
        addSubview(V_stackView)
        
        V_stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(50)
            make.trailing.leading.equalToSuperview().inset(16)
        }
        
        let titles = ["제출 번호","문제", "제출자", "메모리 사용", "실행 시간", "제출 결과"]
        let labels = [problemID,
                      problemName,
                      member,
                      memoryUsage,
                      cpuTime,
                      statuscode]
        
        let map = zip(titles,labels).map{ ($0,$1) }
        
        zip(map,H_stackViews).forEach { map, hstack in
            let (title,label) = map
            hstack.addArrangedSubview(label)
            V_stackView.addArrangedSubview(hstack)
            label.snp.makeConstraints { make in
                make.width.equalTo(maxWidth)
                make.height.equalTo(maxHeight)
            }
            label.layer.borderColor = UIColor.sky_blue.cgColor
            label.setContainer(ReusltStatusView.font, "\(title)")
            label.settingBorader(color: UIColor.sky_blue.cgColor)
        }
        
        H_stackViews.forEach { stack in
            let label = BoxContainerLabel()
            
            stack.addArrangedSubview(label)
            
            label.snp.makeConstraints { make in
                make.width.equalTo(maxWidth)
                make.height.equalTo(maxHeight)
            }
            
            label.setContainer(ReusltStatusView.font, "N/A")
            label.settingBorader(color: UIColor.juhwang.cgColor,corner: 0)
        }
    }
    

}

