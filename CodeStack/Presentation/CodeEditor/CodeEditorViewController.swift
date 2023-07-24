//
//  CodeEditorViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/18.
//

import UIKit
import Highlightr
import SnapKit
import RxFlow
import RxCocoa

class CodeEditorViewController: UIViewController,Stepper{
    
    var steps = PublishRelay<Step>()
    
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
        textView.layer.borderColor = UIColor.systemGray6.cgColor
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
        Log.debug("CodeEditorViewController : deinit")
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutConfigure()
        
        self.view.backgroundColor = .systemBackground
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let storage = (self.codeUITextView.textStorage as! CodeAttributedString)
        self.highlightr?.setTheme(to: "Chalk")
        self.codeUITextView.backgroundColor = self.highlightr?.theme.themeBackgroundColor
        storage.language = "swift"
        guard let path = Bundle.main.path(forResource: "default", ofType: "txt",inDirectory: "\(storage.language!)",forLocalization: nil) else {return}
        guard let strings = try? String(contentsOfFile: path) else {return}
        self.codeUITextView.text = strings
        
        // Dependency TextView injection in NumbersVIew
        self.numbersView.settingTextView(self.codeUITextView,contentSize: self)
        
        self.view.bringSubviewToFront(problemPopUpView)
        
        self.problemPopUpView.show()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    private func keyBoardLayoutManager(){
        let _ = KeyBoardManager.shared.getKeyBoardLifeCycle()
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
        
        
        //MARK: TextContainer Inset -> 넘버 뷰의 위치의 텍스트입력 방지 inset
        var inset = codeUITextView.textContainerInset
        
        inset.left = 35
        codeUITextView.textContainerInset = inset
        numbersView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.bottom.equalToSuperview()
            make.height.equalTo(codeUITextView.bounds.height)
            make.width.equalTo(inset.left).priority(.high)
        }
        // numbersView exclusionPath
    }
    
    //MARK: - Code HighLiter
    private func settingHighliter(){
        let highlightr = Highlightr()
        highlightr?.setTheme(to: "paraiso-dark")
    }
    
}

//MARK: TextView Size Tracker
extension CodeEditorViewController: TextViewSizeTracker{
    func updateNumberViewsHeight(_ height: CGFloat){
        numbersView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
}


//MARK: - 코드 문제 설명 뷰의 애니메이션 구현부
extension CodeEditorViewController{

    /// ProblemComplete
    func spreadCompleteEvnet(){
        steps.accept(CodestackStep.problemComplete)
    }
    
    func showProblemDiscription(){
        problemPopUpView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(400)
        }
        numbersView.layer.setNeedsDisplay()
        self.codeUITextView.contentSize.height += problemPopUpView.bounds.height
    }
    
    func dismissProblemDiscription(button height: CGFloat ){
        problemPopUpView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(height)
        }
        numbersView.layer.setNeedsDisplay()
        
    }
}


//MARK: - TextView delegate
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


