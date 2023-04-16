
//
//  label.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit


extension UILabel{
    func introduceLable(_ size: CGFloat, _ text: String) -> Self{
        let descriptor = self.create_descriptor(style: .headline)
        
        self.font = UIFont(descriptor: descriptor, size: size)
        
        self.text = "\(text)"
        self.textAlignment = .center
        self.numberOfLines = 0
        self.textColor = .white
        return self
    }
    
    private func create_descriptor(style: UIFont.TextStyle, bold: Bool = true) -> UIFontDescriptor{
        var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        
        if bold{
            descriptor = descriptor.withSymbolicTraits(.traitBold)!
        }
        
        return descriptor
    }
    
    func headLineLabel(size: CGFloat = 28,text: String, color: UIColor = UIColor.label) -> Self{
        let label = self.introduceLable(size, text)
        label.textColor = color
        return label
    }
    
    func descriptionLabel(size: CGFloat = 13, text: String, color: UIColor = UIColor.placeholderText) -> Self{
        let descriptor = self.create_descriptor(style: .callout)
        let font = UIFont(descriptor: descriptor, size: size)
        self.text = text
        self.font = font
        self.textColor = color
        return self
    }
}


