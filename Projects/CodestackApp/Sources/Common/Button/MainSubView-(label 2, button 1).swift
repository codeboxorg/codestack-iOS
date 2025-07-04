

import UIKit
import RxCocoa
import CommonUI

///  Title Label 1개
///  description Label 1개
///  action Button 1개
///   Vertical
class TwoLabelOneButton: UIView{
    
    struct LabelBtnText{
        let headLine: String
        let description: String
        let btn_title: String
    }
    
    private lazy var headLine_label: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 8
        return label.headLineLabel(text: "오늘의 문제 보러가기")
    }()
    
    private lazy var description_label: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 4
        return label.descriptionLabel(text: "오늘도 같이 문제를 해결하러 가볼까요?")
    }()
    
    lazy var today_problem_btn: HighlightButton = {
        let button = HighlightButton(frame: .zero)
        return button
    }()

    var buttonType: ButtonType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func buttonTapSignal() -> Signal<ButtonType>{
        today_problem_btn.rx.tap.map{ self.buttonType! }.asSignal(onErrorJustReturn: .none)
    }
    
    private var observation : NSKeyValueObservation?
    
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
                       button.configuration = .tinted()
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
    let offset_top_head: CGFloat = 20
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
