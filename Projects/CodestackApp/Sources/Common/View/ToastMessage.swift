//
//  ToastMessage.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/22.
//

import UIKit


class ToastMessageView: UIView {
    
    var message: String?
    
    private lazy var toastContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var toastLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0
        
        self.layer.cornerRadius = 8
        
        self.addSubview(toastLabel)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        toastLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 12).isActive = true
        toastLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12).isActive = true
        toastLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        toastLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12).isActive = true
    }
    
    convenience init(x positionX: CGFloat,
                     y positionY: CGFloat = 0,
                     offset: CGFloat,
                     messgae: String,
                     font: UIFont,
                     background color: UIColor) {
        
        let width = Position.screenWidth - (positionX * 2)
        
        let height = messgae.height(withConstrainedWidth: width, font: font) + 24
        
        let frame = Position.getPosition(xPosition: positionX,
                                         yPosition: positionY,
                                         yOffset: offset,
                                         defaultWidth: width,
                                         defaultHeight: height)
        self.init(frame: frame)
        self.backgroundColor = color
        self.toastLabel.font = font
        self.toastLabel.text = messgae
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
    
}


