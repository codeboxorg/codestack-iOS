
//
//  label.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import CommonUI


extension UILabel {
    
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
}
