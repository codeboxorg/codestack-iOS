
//
//  label.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit



extension UILabel{
    
    func pr_status_label(_ status: SolveStatus, default placeHolder: Bool = true){
        let string = applyAttribute(text: status.value , color: status.color)
        self.attributedText = string
    }
    
    private func applyAttribute(text: String, color: UIColor, placeHolder: Bool = true) -> NSAttributedString{
        let attributedString = NSMutableAttributedString()
        var attributed: [NSAttributedString.Key : Any]
        
        attributed = [NSAttributedString.Key.foregroundColor : color,
                      .font : UIFont.preferredFont(forTextStyle: .largeTitle)]
        attributedString.append(NSAttributedString(string: "•",attributes: attributed))
        if placeHolder {
            let newLineText = text.replacingOccurrences(of: " ", with: "\n")
            attributedString.append(NSAttributedString(string: "\(newLineText)",
                                                       attributes: [.font : UIFont.systemFont(ofSize: 14),
                                                                    .baselineOffset : 5 ,
                                                                    .foregroundColor : color]))
        }
        return attributedString
    }
    
    
    func introduceLable(_ size: CGFloat, _ text: String, style: UIFont.TextStyle = .headline) -> Self{
        let descriptor = self.create_descriptor(style: .headline)
        
        self.font = UIFont(descriptor: descriptor, size: size)
        
        self.text = "\(text)"
        self.textAlignment = .center
        self.numberOfLines = 0
        self.textColor = .label
        return self
    }
    
    private func create_descriptor(style: UIFont.TextStyle, bold: Bool = true) -> UIFontDescriptor{
        var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        
        if bold{
            descriptor = descriptor.withSymbolicTraits(.traitBold)!
        }
        
        return descriptor
    }
    
    func headLineLabel(size: CGFloat = 28,text: String = "", color: UIColor = UIColor.label) -> Self{
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


