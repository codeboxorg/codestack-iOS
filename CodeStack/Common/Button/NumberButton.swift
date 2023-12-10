//
//  NumberButton.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/07.
//

import UIKit
import SnapKit

class NumberButton: UIButton {
    
    var container: UIView = {
        let view = UIView()
        return view
    }()
    
    private let numberLayerContainer: UIView = {
        let number = UIView()
        number.layer.borderColor = UIColor.sky_blue.cgColor
        number.layer.borderWidth = 1
        number.layer.cornerRadius = 5
        return number
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        return label.headLineLabel(size: 16, text: "1", color: .label)
    }()
    
    private let textlabel: UILabel = {
        let label = UILabel()
        return label.headLineLabel(size: 16, text: "결과", color: .label)
    }()
    
    
    func setTextColor(color: UIColor) {
        numberLabel.textColor = color
        textlabel.textColor = color
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
    func settingNumber(for index: Int){
        numberLabel.text = "\(index)"

    }
    
    func settingText(for text: String){
        textlabel.text = text
    }
    
    private func layoutConfigure(){
        
        addSubview(container)
        
        [numberLayerContainer,
         textlabel]
            .forEach{
                container.addSubview($0)
        }
        
        numberLayerContainer.addSubview(numberLabel)
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        numberLayerContainer.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(5)
            make.width.height.equalTo(30)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        textlabel.snp.makeConstraints { make in
            make.leading.equalTo(numberLayerContainer.snp.trailing).offset(5)
            make.centerY.equalTo(numberLayerContainer.snp.centerY)
            make.trailing.equalToSuperview().inset(5)
        }
    }
}
