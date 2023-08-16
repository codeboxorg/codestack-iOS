
//
//  label.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit



extension UILabel{
    
    func pr_status_label(_ status: SolveStatus, default placeHolder: Bool = true){
        let attributedString = NSMutableAttributedString()
        
        var attributed: [NSAttributedString.Key : Any]
        
        switch status {
        case .favorite:
            attributed = [NSAttributedString.Key.foregroundColor : UIColor.systemYellow,
                          .font : UIFont.preferredFont(forTextStyle: .largeTitle)]
            attributedString.append(NSAttributedString(string: "•",attributes: attributed))
            if placeHolder {
                attributedString.append(NSAttributedString(string: "즐겨찾기",
                                                           attributes: [.font : UIFont.systemFont(ofSize: 10),
                                                                        .baselineOffset : 6 ]))
            }
            
        case .temp:
            attributed = [NSAttributedString.Key.foregroundColor : UIColor.lightGray,
                          .font : UIFont.preferredFont(forTextStyle: .largeTitle)]
            attributedString.append(NSAttributedString(string: "•",attributes: attributed))
            if placeHolder {
                attributedString.append(NSAttributedString(string: "임시저장",
                                                           attributes: [.font : UIFont.systemFont(ofSize: 10),
                                                                        .baselineOffset : 6 ]))
            }
        case .solve:
            attributed = [NSAttributedString.Key.foregroundColor : UIColor.green,
                          .font : UIFont.preferredFont(forTextStyle: .largeTitle)]
            attributedString.append(NSAttributedString(string: "•",attributes: attributed))
            if placeHolder {
                attributedString.append(NSAttributedString(string: "성공",
                                                           attributes: [.font : UIFont.systemFont(ofSize: 10),
                                                                        .baselineOffset : 6 ]))
            }
        case .fail:
            attributed = [NSAttributedString.Key.foregroundColor : UIColor.red,
                          .font : UIFont.preferredFont(forTextStyle: .largeTitle)]
            attributedString.append(NSAttributedString(string: "•",attributes: attributed))
            if placeHolder{
                attributedString.append(NSAttributedString(string: "실패",
                                                           attributes: [.font : UIFont.systemFont(ofSize: 10),
                                                                        .baselineOffset : 6 ]))
            }
        case .none:
            break
        }
        
        self.attributedText = attributedString
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


