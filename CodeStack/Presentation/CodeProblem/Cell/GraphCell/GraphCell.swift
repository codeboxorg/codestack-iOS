//
//  GraphCell.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/16.
//

import UIKit
import SnapKit



class GraphSubmitView: UIView{
    
    let lableSize: CGFloat = 14
    
    private lazy var submitLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 10
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var submitStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 10
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var problem_submit_Label: UILabel = {
        let label = UILabel().headLineLabel(size: lableSize)
        label.text = "제출"
        return label
    }()
    
    private lazy var problem_submit_tag: UILabel = {
        let label = UILabel().headLineLabel(size: lableSize)
        label.text = "제출"
        return label
    }()
    
    private lazy var problem_correct_Label: UILabel = {
        let label = UILabel().headLineLabel(size: lableSize)
        label.text = "정답"
        return label
    }()
    
    private lazy var problem_correct_tag: UILabel = {
        let label = UILabel().headLineLabel(size: lableSize)
        label.text = "정답"
        return label
    }()
    
    private lazy var problem_correctRate_Label: UILabel = {
        let label = UILabel().headLineLabel(size: lableSize)
        label.text = "정답률"
        return label
    }()
    
    
    private lazy var problem_correctRate_tap: UILabel = {
        let label = UILabel().headLineLabel(size: lableSize)
        label.text = "정답률"
        return label
    }()
    
    private lazy var separatorView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    private lazy var separatorView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    private lazy var separatorView3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    private lazy var separatorView4: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    private lazy var separatorView_start: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    private lazy var separatorView_end: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    private lazy var separatorView_start2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    private lazy var separatorView_end2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutConfigure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    deinit{
        print("\(String(describing: Self.self)) - deinint")
    }
    
    struct GraphModel{
        var submitCount: String?
        var correctAnswer: String?
        var correctRate: String?
    }
    
    func bind(_ model: GraphModel?){
        if let model {
            problem_submit_tag.text = "\(model.submitCount ?? "0")"
            problem_correct_tag.text = "\(model.correctAnswer ?? "0")"
            problem_correctRate_tap.text = "\(model.correctRate ?? "0")"
        }
    }
    
    
    let topSpacing: CGFloat = 8
    
    private func getFontSize(_ view: UIView) -> CGSize{
        return view.sizeThatFits(CGSize())
    }
    
    lazy var separatorHeight = topSpacing + getFontSize(problem_submit_tag).height
    
    func getCellSize() -> CGSize{
        return CGSize()
    }
    
    private func layoutConfigure(){
        
        
        let separatorHeight = separatorHeight
        
        addSubview(submitLabelStackView)
        addSubview(submitStackView)
        
        submitLabelStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        submitLabelStackView.layer.borderColor = UIColor.lightGray.cgColor
        submitLabelStackView.layer.borderWidth = 1
        
        submitStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50).priority(.high)
        }
        
        
        [
            separatorView_start2,
            problem_submit_Label,
            separatorView3,
            problem_correct_Label,
            separatorView4,
            problem_correctRate_Label,
            separatorView_end2
        ].forEach{
            submitLabelStackView.addArrangedSubview($0)
        }
        
        separatorView_start2.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(separatorHeight).priority(.low)
        }
        
        
        separatorView3.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(separatorHeight).priority(.low)
        }
        

        separatorView4.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(separatorHeight).priority(.low)
            make.bottom.equalToSuperview()
        }
        

        separatorView_end2.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(separatorHeight).priority(.low)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        [
            separatorView_start,
            problem_submit_tag,
            separatorView1,
            problem_correct_tag,
            separatorView2,
            problem_correctRate_tap,
            separatorView_end
            //            separatorView3
        ].forEach{
            submitStackView.addArrangedSubview($0)
        }
        
        separatorView_start.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(separatorHeight).priority(.low)
        }
        
        
        separatorView1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(separatorHeight).priority(.low)
        }
        

        separatorView2.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(separatorHeight).priority(.low)
            make.bottom.equalToSuperview()
        }
        

        separatorView_end.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(separatorHeight).priority(.low)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

//MARK: Cell Identifier
//extension GraphCell: CellIdentifierProtocol{}
