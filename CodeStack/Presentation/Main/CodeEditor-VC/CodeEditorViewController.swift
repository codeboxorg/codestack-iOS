//
//  CodeEditorViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/18.
//

import UIKit
import Highlightr
import SnapKit

class CodeEditorViewController: UIViewController{
    
    
    private lazy var numberTextViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    lazy var codeUITextView: CodeUITextView = {
        let textStorage = CodeAttributedString()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate = self
        let textView = CodeUITextView(frame: .zero, textContainer: textContainer)
        textView.delegate = self
        textView.layer.borderColor = UIColor.systemCyan.cgColor
        textView.layer.borderWidth = 1
        textView.spellCheckingType = .no
        return textView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutConfigure()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = .systemPink
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            let storage = (self.codeUITextView.textStorage as! CodeAttributedString)
            storage.highlightr.setTheme(to: "vs")
            self.codeUITextView.backgroundColor = storage.highlightr.theme.themeBackgroundColor
            storage.language = "swift"
            guard let path = Bundle.main.path(forResource: "default", ofType: "txt",inDirectory: "\(storage.language!)",forLocalization: nil) else {return}
            guard let strings = try? String(contentsOfFile: path) else {return}
            self.codeUITextView.text = strings
            self.getRect()
            
        })
        
        
    }
    func getWholeParagraphCount() -> Int{
        let storage2 = (self.codeUITextView.textStorage)
        var startPointer = 0
        var endPointer = 0
        var cotentsEnds = 0
        let nsString = (storage2.string as NSString)
        
        storage2.mutableString.getParagraphStart(&startPointer, end: &endPointer, contentsEnd: &cotentsEnds, for: NSRange(location: 0, length: storage2.string.count))
        print("startPointer: \(startPointer)")
        print("endPointer: \(endPointer)")
        print("cotentsEnds: \(cotentsEnds)")
        
        return 0
    }
    
    func getRect(){
        let firstParagraphRange = codeUITextView.textStorage.mutableString.paragraphRange(for: NSRange(location: 0, length: 1))
        
        let wholeRangeOf_textView = NSRange(location: 0, length: codeUITextView.textStorage.string.count)
        
        codeUITextView.layoutManager
            .enumerateEnclosingRects(forGlyphRange: wholeRangeOf_textView,
                                     withinSelectedGlyphRange: firstParagraphRange,
                                     in: codeUITextView.textContainer,
                                     using: {
                rect,objcBool in
                
                let y = self.numberTextViewContainer.frame.origin.y
                let x = self.codeUITextView.frame.origin.x
                
                let rect = CGRect(x: x, y: y, width: rect.width, height: rect.height)
                let view = UIView(frame: rect)
                view.backgroundColor = .lightGray
                view.alpha = 0.5
                self.view.addSubview(view)
                objcBool.pointee = true
                
            })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func keyBoardLayoutManager(){
        let output = KeyBoardManager.shared.getKeyBoardLifeCycle()
        
    }
    
    private func layoutConfigure(){
        self.view.addSubview(numberTextViewContainer)
        numberTextViewContainer.addSubview(codeUITextView)
        
        numberTextViewContainer.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
            make.height.equalTo(self.view.snp.height).priority(.low)
        }
        
        codeUITextView.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(16)
        }
        
        
    }
    
    //MARK: - Code HighLiter
    private func settingHighliter(){
        let highlightr = Highlightr()
        highlightr?.setTheme(to: "paraiso-dark")
        //        let code = "let a = 1"
        // You can omit the second parameter to use automatic language detection.
        //        let highlightedCode = highlightr?.highlight(code, as: "swift")
        
    }
    
}

extension CodeEditorViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange(_ textView: UITextView) {")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("shouldChangeTextIn")
        print("text: \(text)")
        return true
    }
}


extension CodeEditorViewController: NSLayoutManagerDelegate{
    func layoutManager(_ layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}
