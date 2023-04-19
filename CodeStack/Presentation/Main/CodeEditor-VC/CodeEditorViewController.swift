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
    
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var numberTextViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private lazy var numbersView: LineNumberRulerView = {
        let view = LineNumberRulerView(frame: .zero, textView: nil)
        
        return view
    }()
    
    deinit{
        print("CodeEditorViewController : deinit")
        
    }
    
    weak var highlightr: Highlightr?
    
    lazy var codeUITextView: CodeUITextView = {
        let textStorage = CodeAttributedString()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)
        
        highlightr = textStorage.highlightr
        
        layoutManager.delegate = self
        let textView = CodeUITextView(frame: .zero, textContainer: textContainer)
        textView.delegate = self
        textView.isScrollEnabled = true
        textView.layer.borderColor = UIColor.systemCyan.cgColor
        textView.layer.borderWidth = 1
        textView.spellCheckingType = .no
        textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.autocapitalizationType = UITextAutocapitalizationType.none
        //        codeUITextView.textContainer.heightTracksTextView
        
        return textView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutConfigure()
        numbersView.settingTextView(self.codeUITextView)
        self.view.backgroundColor = .systemPink
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            guard let self else {return}
            let storage = (self.codeUITextView.textStorage as! CodeAttributedString)
            self.highlightr?.setTheme(to: "vs")
            self.codeUITextView.backgroundColor = self.highlightr?.theme.themeBackgroundColor
            storage.language = "swift"
            guard let path = Bundle.main.path(forResource: "default", ofType: "txt",inDirectory: "\(storage.language!)",forLocalization: nil) else {return}
            guard let strings = try? String(contentsOfFile: path) else {return}
            self.codeUITextView.text = strings
//            self.getRect()
        })
    }
    
    func getRect(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
            guard let self else {return}
            let firstParagraphRange = self.codeUITextView.textStorage.mutableString.paragraphRange(for: NSRange(location: 0, length: 1))
            
            let start = Date()
            
            guard let text = self.codeUITextView.text else { return }
            
            var paragraphRanges: [NSRange] = []
            
            text.enumerateSubstrings(in: text.startIndex..<text.endIndex , options: .byParagraphs, { (
                substring, substringRange, _, _) in
                // Convert the substring range to an NSRange
                let nsRange = NSRange(substringRange, in: text)
                // Add the NSRange to the array of paragraph ranges
                paragraphRanges.append(nsRange)
            })
            
            let wholeRangeOf_textView = NSRange(location: 0, length: self.codeUITextView.textStorage.string.count)
            let notFound = NSRange(location: NSNotFound, length: 0)
            
            paragraphRanges.forEach { range in
                self.codeUITextView
                    .layoutManager
                    .enumerateEnclosingRects(forGlyphRange: range,
                                             withinSelectedGlyphRange: notFound,
                                             in: self.codeUITextView.textContainer,
                                             using: {
                        rect,objcBool in
                        let color = [UIColor.black,UIColor.systemRed,UIColor.blue,UIColor.green,UIColor.brown, UIColor.cyan ].randomElement() ?? UIColor.gray
                        
                        let y = rect.origin.y
                        let x = rect.origin.x
                        
                        let rect = CGRect(x: x,
                                          y: y + self.codeUITextView.textContainerInset.top,
                                          width: rect.width + 1,
                                          height: rect.height)
                        
                        let view = UIView(frame: rect)
                        view.backgroundColor = color
                        view.alpha = 0.5
                        self.codeUITextView.addSubview(view)
                        print("Range: \(range) \n Rect: \(rect) \n")
                        
                    })
            }
            let end = Date()
            let time = Float(end.timeIntervalSince(start));
            print("performance: \(time)")
        })
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func keyBoardLayoutManager(){
//        let output = KeyBoardManager.shared.getKeyBoardLifeCycle()
        
    }
    
    let uiview = UIView(frame: .zero)
    
    private func layoutConfigure(){

        self.view.addSubview(numberTextViewContainer)
        numberTextViewContainer.addSubview(codeUITextView)
        codeUITextView.addSubview(numbersView)
        
        numberTextViewContainer.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
            make.height.equalTo(self.view.snp.height).priority(.low)
        }
        
        codeUITextView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
        numbersView.backgroundColor = .systemBlue
        
        numbersView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.bottom.equalToSuperview()
            make.height.equalTo(codeUITextView.snp.height)
            make.width.equalTo(30).priority(.high)
        }
        
        // numbersView exclusionPath
        var inset = codeUITextView.textContainerInset
        inset.left = 30
        codeUITextView.textContainerInset = inset
    }
    
    //MARK: - Code HighLiter
    private func settingHighliter(){
        let highlightr = Highlightr()
        highlightr?.setTheme(to: "paraiso-dark")
    }
    
}

extension CodeEditorViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
     
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
}

extension CodeEditorViewController: NSLayoutManagerDelegate{
    func layoutManager(_ layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}


