//
//  ContainerLabel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import UIKit
import Global

class BoxContainerLabel: UILabel{
    
    private let maxWidth: (String,UIFont) -> CGFloat =
    { text, font in
        
        "\(text)".width(withConstrainedHeight: 0, font: font) + 40
    }
    
    private let maxHeight: (String,UIFont) -> CGFloat =
    { text, font in
        "\(text)".height(withConstrainedWidth: 0, font: font) + 10
    }
    
    private let container: UIView = {
        let view = UIView()
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
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
        addSubview(container)
        container.addSubview(label)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: self.topAnchor),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor)  
        ])
    }
    
    func settingBorader(color: CGColor, width: CGFloat = 1, corner: CGFloat = 8){
        container.layer.borderColor = color
        container.layer.borderWidth = 1
        container.layer.cornerRadius = corner
    }
    
    func setContainer(_ font: UIFont = UIFont.boldSystemFont(ofSize: 16),
                      _ text: String)
    {
//        DispatchQueue.main.async { [weak self] in
//            guard let self else {return }
        self.layoutIfNeeded()
        self.label.font = font
        self.label.text = text
        self.label.sizeToFit()
        self.label.center = container.center
//        }
    }
    
}
