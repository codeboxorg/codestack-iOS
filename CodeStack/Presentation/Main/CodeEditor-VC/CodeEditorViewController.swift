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
        textView.alwaysBounceVertical = true
        
        return textView
    }()
    
    
    lazy var problemPopUpView: ProblemPopUpView = {
        let popView = ProblemPopUpView(frame: .zero,self)
        return popView
    }()
    
    
    deinit{
        print("CodeEditorViewController : deinit")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutConfigure()
        
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
            
            // Dependency TextView injection in NumbersVIew
            self.numbersView.settingTextView(self.codeUITextView)
            self.view.bringSubviewToFront(problemPopUpView)
            self.problemPopUpView.show()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func keyBoardLayoutManager(){
//        let output = KeyBoardManager.shared.getKeyBoardLifeCycle()
    }
    
    private func layoutConfigure(){
        self.view.addSubview(problemPopUpView)
        self.view.addSubview(numberTextViewContainer)
        numberTextViewContainer.addSubview(codeUITextView)
        codeUITextView.addSubview(numbersView)
        
        problemPopUpView.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(60)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(400)
        }
        
        numberTextViewContainer.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
            make.height.equalTo(self.view.snp.height).priority(.low)
        }
        
        codeUITextView.snp.makeConstraints { make in
            make.top.equalTo(problemPopUpView.snp.bottom)
            make.trailing.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        
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

extension CodeEditorViewController{
    func showProblemDiscription(){
        problemPopUpView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300).priority(.low)
        }
        numbersView.layer.isHidden = true
        numbersView.layer.setNeedsDisplay()
        
        self.codeUITextView.contentSize.height += problemPopUpView.bounds.height
    }
    
    func dismissProblemDiscription(){
        problemPopUpView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        numbersView.layer.isHidden = true
        numbersView.layer.setNeedsDisplay()
        
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


