//
//  MainSubView-(label 2, button 1).swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit

class TwoLabelOneButton: UIView{
    
    enum ButtonType{
        case today_problem(SideMenuDelegate?)
        case recommand_problem(SideMenuDelegate?)
    }
    
    struct LabelBtnText{
        let headLine: String
        let description: String
        let btn_title: String
    }
    
    private lazy var headLine_label: UILabel = {
        let label = UILabel()
        return label.headLineLabel(text: "오늘의 문제 보러가기")
    }()
    
    private lazy var description_label: UILabel = {
        let label = UILabel()
        return label.descriptionLabel(text: "오늘도 같이 문제를 해결하러 가볼까요?")
    }()
    
    lazy var today_problem_btn: HighlightButton = {
        let button = HighlightButton(frame: .zero)
        button.addTarget(self, action: #selector(navigationButton(_:)), for: .touchUpInside)
        return button
    }()

    var buttonType: ButtonType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    @objc func navigationButton(_ sender: UIButton){
        //viewModel 에 주입 해서 navigation 하면 될거 같은데
        guard let buttonType else {return}
        switch buttonType{
        case .today_problem(let delegate):
            delegate?.moveToVC("문제")
        case .recommand_problem(let delegate):
            delegate?.moveToVC("추천")
        }
        
    }
    
    var observation : NSKeyValueObservation?
    
    convenience init(frame: CGRect, labelBtnText: LabelBtnText){
        self.init(frame: .zero)
        
        layoutConfigure()
        
        headLine_label.text = labelBtnText.headLine
        description_label.text = labelBtnText.description
        today_problem_btn.setTitle(labelBtnText.btn_title, for: .normal)
        
        observation = today_problem_btn.observe(\.isHighlighted, options: [.old, .new], changeHandler: { button, change in
               if change.oldValue! != change.newValue! {
                   guard let highlighetd = change.newValue else { return }
                   if highlighetd{
                       button.configuration = .filled()
                   }else{
                       button.configuration = .plain()
                   }
               }
           })
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
    // offset
    let leading: CGFloat = 16
    let offset_top_head: CGFloat = 35
    let offset_top_desc: CGFloat = 12
    let offset_top_btn: CGFloat = 20
    let button_height: CGFloat = 44
    
    
    /// getViewHeight
    /// - Returns: 전체뷰의 높이를 반환하는 함수입니다.
    func getViewHeight() -> CGFloat{
        let result = offset_top_btn + offset_top_desc + offset_top_head + button_height + headLine_label.sizeThatFits(CGSize()).height + description_label.sizeThatFits(CGSize()).height
        return result
    }
    
    private func layoutConfigure(){
        
        self.addSubview(headLine_label)
        self.addSubview(description_label)
        self.addSubview(today_problem_btn)
        
        
        headLine_label.snp.makeConstraints{
            $0.top.equalTo(self.snp.top).offset(offset_top_head)
            $0.leading.equalToSuperview().inset(leading)
        }
        
        description_label.snp.makeConstraints{
            $0.top.equalTo(headLine_label.snp.bottom).offset(offset_top_desc)
            $0.leading.equalToSuperview().inset(leading)
        }
        
        today_problem_btn.snp.makeConstraints{
            $0.top.equalTo(description_label.snp.bottom).offset(offset_top_btn)
            $0.leading.equalToSuperview().inset(leading)
            $0.height.equalTo(button_height)
        }
    }
    
}
