//
//  UILabel.swift
//  CommonUI
//
//  Created by 박형환 on 2/1/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit


extension UILabel {
    func create_descriptor(style: UIFont.TextStyle, bold: Bool = true) -> UIFontDescriptor{
        var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        
        if bold{
            descriptor = descriptor.withSymbolicTraits(.traitBold)!
        }
        
        return descriptor
    }
    
    public func introduceLable(_ size: CGFloat, _ text: String, style: UIFont.TextStyle = .headline) -> Self{
        let descriptor = self.create_descriptor(style: .headline)
        
        self.font = UIFont(descriptor: descriptor, size: size)
        
        self.text = "\(text)"
        self.textAlignment = .center
        self.numberOfLines = 0
        self.textColor = .label
        return self
    }
    
    public func headLineLabel(size: CGFloat = 28,text: String = "", color: UIColor = UIColor.label) -> Self{
        let label = self.introduceLable(size, text)
        label.textColor = color
        return label
    }
    
    public func descriptionLabel(size: CGFloat = 13, text: String, color: UIColor = UIColor.placeholderText) -> Self{
        let descriptor = self.create_descriptor(style: .callout)
        let font = UIFont(descriptor: descriptor, size: size)
        self.text = text
        self.font = font
        self.textColor = color
        return self
    }
}
