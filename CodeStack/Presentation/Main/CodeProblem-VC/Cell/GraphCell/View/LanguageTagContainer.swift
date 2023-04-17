//
//  LanguageTagView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/17.
//

import UIKit


class LanguageTagContainer: UIView {

    private var maxWidth = UIApplication.shared.keyWindow!.frame.width
    
    private var currentWidth: CGFloat = 0
    
    private var currentHight: CGFloat = 0
    
    private var spacing: CGFloat = 12
    
    override var intrinsicContentSize: CGSize {
        
        let item = LanguageTag()
        
        item.setText(text: "test")
        
        let height = item.sizeThatFits(CGSize()).height
        
        let itemSpacing: CGFloat = 24
        
        return CGSize(width: self.maxWidth,
                      height: self.currentHight + height + itemSpacing)
    }
    
    override init(frame: CGRect) {
        self.maxWidth = frame.width
        super.init(frame: frame)
    }
    
    var laguageTag: LanguageTag? {
        didSet{
            guard let languageTag = self.laguageTag else {return}
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
    
    private var fetures: [String] = [] {
        didSet{
            self.fetures.forEach{ string in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    let view = LanguageTag()
                    self.addSubview(view)
                    view.setText(text: string)
                    view.bounds = CGRect(x: 0, y: 0,
                                         width: view.getItemWidh(),
                                         height: view.getItemHeight() )
                    self.laguageTag = view
                }
                return
            }
        }
    }
    
    private func settingFeatureView(_ features : [String]) {
        if self.subviews != [] {
            self.subviews.forEach{
                $0.removeFromSuperview()
                self.currentWidth = 0
                self.currentHight = 0
            }
        }
        self.fetures = features
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
}
