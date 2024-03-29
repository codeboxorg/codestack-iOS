//
//  LanguageTagView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/17.
//

import UIKit
import Domain
import CommonUI

extension String{
    func getColor() -> UIColor{
        switch self{
        case "C":
            return .red_c
        case "C++":
            return .juhwang_2
        case "Python3":
            return .magenta
        case "Node.js":
            return .systemGreen
        case "GO":
            return .systemMint
        case "구현":
            return .systemPurple
        case "수학":
            return .yellow
        default:
            return .magenta
        }
    }
}

class TagContainer: UIView {
    
    // TODO: - Backgournd Error ?
    private var maxWidth = Position.screenWidth
    
    private var currentWidth: CGFloat = 0
    
    private var currentHight: CGFloat = 0
    
    var spacing: CGFloat = 8
    
    private var fetures: [String] = []
    
    override var intrinsicContentSize: CGSize {
        let item = TagView()
        item.setText(text: "test")
        let height = item.sizeThatFits(CGSize()).height
        let inset: CGFloat = 8
        let size = CGSize(width: self.maxWidth,
                          height: self.currentHight + height + (spacing * 2) + inset )
        return size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, spacing: CGFloat) {
        self.init(frame: frame)
        self.maxWidth = frame.width
        self.spacing = spacing
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    func removeLaguageTag() {
        self.subviews.forEach{
            $0.removeFromSuperview()
        }
        self.currentHight = 0
        self.currentWidth = 0
        invalidateIntrinsicContentSize()
    }
    
    func setTagItem(_ items: [String]) {
        fetures = items
        feturesUpdate()
    }
    
    func setLanguage(_ language: [LanguageVO]){
        fetures = language.map{ $0.name }
        feturesUpdate()
    }
    
    
    func getCurrentIntrinsicHeight() -> CGFloat {
        return self.intrinsicContentSize.height
    }
    
    private func feturesUpdate(){
        self.fetures.forEach { string in
            let tag = TagView(frame: .zero, corner: 8, background: string.getColor(), text: .black)
            self.addSubview(tag)
            tag.setText(text: string)
            tag.bounds = CGRect(x: 0, y: 0, width: tag.getItemWidh(), height: tag.getItemHeight() )
            addLanguageTags(tag)
        }
    }
    
    private func addLanguageTags(_ tag: TagView?) {
        guard let languageTag = tag else {return}
        if self.currentWidth == 0  {
            languageTag.frame = CGRect(x: spacing, y: 0,
                                       width: languageTag.bounds.width, height: languageTag.bounds.height)
            currentWidth += spacing
        }else {
            if maxWidth >= (self.currentWidth + languageTag.bounds.width + spacing){
                languageTag.frame = CGRect(x: self.currentWidth, y: self.currentHight,
                                           width: languageTag.bounds.width, height: languageTag.bounds.height)
            }else {
                self.currentHight += languageTag.bounds.height + spacing
                self.currentWidth = spacing
                languageTag.frame = CGRect(x: self.currentWidth , y: self.currentHight,
                                           width: languageTag.bounds.width, height: languageTag.bounds.height)
            }
        }
        self.currentWidth += languageTag.bounds.width + spacing
        
        invalidateIntrinsicContentSize()
    }
}
