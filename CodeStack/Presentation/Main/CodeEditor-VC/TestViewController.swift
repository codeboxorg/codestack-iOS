//
//  TestViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/19.
//

import UIKit
import SnapKit

class TestViewController: UIViewController {
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemPink
        self.view.addSubview(textView)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        textView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges).inset(15)
        }
        textView.textColor = UIColor.black
        textView.text = "안녕하세요저는 박형환ㅇ비ㅣ나당ㄹ님ㅇ러ㅏㅁ닝러안녕하세요저는 박형환ㅇ비ㅣ나당ㄹ님ㅇ러ㅏㅁ닝러안녕하세요저는 박형환ㅇ비ㅣ나당ㄹ님ㅇ러ㅏㅁ닝러안녕하세요저는 박형환ㅇ비ㅣ나당ㄹ님ㅇ러ㅏㅁ닝러안녕하세요저는 박형환ㅇ비ㅣ나당ㄹ님ㅇ러ㅏㅁ닝러안녕하세요저는 박형환ㅇ비ㅣ나당ㄹ님ㅇ러ㅏㅁ닝러안녕하세요저는 박형환ㅇ비ㅣ나당ㄹ님ㅇ러ㅏㅁ닝러안녕하세요저는 박형환ㅇ비ㅣ나당ㄹ님ㅇ러ㅏㅁ닝러"
        
        let firstParagraphRange = textView.textStorage.mutableString.paragraphRange(for: NSRange(location: 0, length: 1))
        
        let wholeRangeOf_textView = NSRange(location: 0, length: textView.textStorage.string.count)
        
        textView.layoutManager
            .enumerateEnclosingRects(forGlyphRange: firstParagraphRange,
                                     withinSelectedGlyphRange: firstParagraphRange,
                                     in: textView.textContainer,
                                     using: {
                rect,objcBool in
            
                let x = self.textView.frame.origin.x
                let y = self.textView.frame.origin.y
                
                
                
                let view = UIView(frame: rect)
                view.backgroundColor = .blue
                view.alpha = 0.5
                self.textView.addSubview(view)
 
            })
    }
}
