//
//  GraphCell.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/16.
//

import UIKit
import SnapKit


class GraphCell: UICollectionViewCell{
    
    let lableSize: CGFloat = 14
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 10
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var problem_submit_tag: UILabel = {
        let label = UILabel().headLineLabel(size: lableSize)
        label.text = "제출"
        return label
    }()
    
    private lazy var subMitContainer: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private lazy var problem_correct_tag: UILabel = {
        let label = UILabel().headLineLabel(size: lableSize)
        label.text = "정답"
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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutConfigure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
    struct GraphModel{
        var submitCount: String?
        var correctAnswer: String?
        var correctRate: String?
    }
    
    func bind(_ model: GraphModel?){
        if let model {
            problem_submit_tag.text = "\(model.submitCount!)"
            problem_correct_tag.text = "\(model.correctAnswer!)"
            problem_correctRate_tap.text = "\(model.correctRate!)"
            
            contentView.layer.addBorder(side: .bottom, thickness: 1, color: UIColor.lightGray.cgColor)
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
        
        contentView.addSubview(stackView)
        
        contentView.layer.addBorder(side: .top, thickness: 1, color: UIColor.lightGray.cgColor)
        contentView.layer.addBorder(side: .left, thickness: 1, color: UIColor.lightGray.cgColor)
        contentView.layer.addBorder(side: .right, thickness: 1, color: UIColor.lightGray.cgColor)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50).priority(.low)
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
            stackView.addArrangedSubview($0)
        }
            

        separatorView_start.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(separatorHeight).priority(.low)
            make.bottom.equalToSuperview()
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
extension GraphCell: CellIdentifierProtocol{}
