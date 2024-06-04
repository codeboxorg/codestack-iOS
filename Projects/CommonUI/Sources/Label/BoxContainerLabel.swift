//
//  ContainerLabel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import UIKit
import Global

public final class BoxContainerLabel: UIView {
    
    public var maxWidth: CGFloat {
        "\(label.text ?? "")"
            .width(
                withConstrainedHeight: 0,
                font: label.font
            )
        + 40
    }
    
    public var maxHeight: CGFloat {
        "\(label.text ?? "")"
            .height(
                withConstrainedWidth: 0,
                font: label.font
            )
        + 10
    }
    
    private let container: UIView = {
        let view = UIView()
        return view
    }()
    
    public let label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    public convenience init(
        color: UIColor,
        text: String,
        font: UIFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline),
                              size: 16),
        border: UIColor,
        borderwidth: CGFloat = 1,
        corner: CGFloat = 8
    ) {
        self.init(frame: .zero)
        self.label.textColor = color
        self.label.font = font
        self.label.text = text
        self.container.layer.borderColor = border.cgColor
        container.layer.borderWidth = 1
        container.layer.cornerRadius = corner
    }
    
    private func addAutoLayout(){
        addSubview(container)
        container.addSubview(label)
        container.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: self.topAnchor),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
    
    public func settingBorader(color: CGColor, width: CGFloat = 1, corner: CGFloat = 8){
        container.layer.borderColor = color
        container.layer.borderWidth = 1
        container.layer.cornerRadius = corner
    }
    
    public func setText(_ text: String) {
        self.label.text = text
    }
    
    public func setContainer(_ font: UIFont = UIFont.boldSystemFont(ofSize: 16), _ text: String) {
        label.font = font
        label.text = text
    }
    
}
