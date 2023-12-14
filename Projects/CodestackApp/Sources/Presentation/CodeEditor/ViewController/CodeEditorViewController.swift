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
import Global
import RxSwift

class CodeEditorViewController: UIViewController, Stepper {
    
    var steps = PublishRelay<Step>()
    
    private var editorViewModel: CodeEditorViewModel?
    
    private var disposeBag = DisposeBag()
    
    var problemItem: ProblemListItemModel?
    
    private weak var highlightr: Highlightr?
    
    struct Dependency{
        var viewModel: CodeEditorViewModel
        var problem: ProblemListItemModel
    }
    
    static func create(with dependency: Dependency) -> CodeEditorViewController {
        let vc = CodeEditorViewController()
        vc.editorViewModel = dependency.viewModel
        vc.problemItem = dependency.problem
        vc.problemPopUpView.setLangueMenu(languages: dependency.problem.language)
        return vc
    }
    
    private let numberTextViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let numbersView: LineNumberRulerView = {
        let view = LineNumberRulerView(frame: .zero, textView: nil)
        return view
    }()
    
    
    lazy var codeUITextView: CodeUITextView = {
        let textStorage = CodeAttributedString()
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)
        
        highlightr = textStorage.highlightr
        highlightr?.setTheme(to: "Chalk")
        
        let textView = CodeUITextView(frame: .zero, textContainer: textContainer)
        layoutManager.delegate = self
        textView.delegate = self
        
        return textView
    }()
    
    
    lazy var problemPopUpView: ProblemPopUpView = {
        let popView = ProblemPopUpView(frame: .zero,self)
        
        if let html = problemItem?.contenxt {
            popView.loadHTMLToWebView(html: html)
        }
        
        if let title = problemItem?.problemTitle {
            popView.problemTitle.text = "\(title)"
        }
        return popView
    }()
    

    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutConfigure()
        
        settingBackground()
        self.numbersView.settingTextView(self.codeUITextView,tracker: self)
        self.view.bringSubviewToFront(problemPopUpView)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        binding()
    }
    
    func settingBackground() {
        let black = self.highlightr?.theme.themeBackgroundColor
        
        let white = CColor.whiteGray.color
        
        self.codeUITextView.backgroundColor = black
        self.codeUITextView.layer.borderColor = black?.cgColor
        self.codeUITextView.tintColor = white
        
        numberTextViewContainer.backgroundColor = black
        self.view.backgroundColor = black
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.problemPopUpView.show()   
    }
    
    private var sourceCodeState = false
    
    func binding(){
        let dissmissAction = problemPopUpView.dissmissAction()
        
        if let id = problemItem?.problemNumber,
           let title = problemItem?.problemTitle {
            
            let sendSubmissionAction 
            =
            problemPopUpView
                .sendSubmissionAction()
                .map { _ in "\(id)" }
                .startWith("\(id)")
                .asDriver(onErrorJustReturn: "")
            
            if let sourceCode = problemItem?.sourceCode,
               let language = problemItem?.seletedLanguage {
                codeUITextView.text = sourceCode
                sourceCodeState = true
                if sourceCode.isEmpty { sourceCodeState = false }
                problemPopUpView.languageRelay.accept(language)
            }
            
            if problemItem?.sourceCode == nil {
                sourceCodeState = false
            }
            
            let languageAction = problemPopUpView.languageAction()
            
            let textChange = codeUITextView.rx.text
                .debounce(.milliseconds(300),
                          scheduler: MainScheduler.instance)
                .compactMap { $0 }
                .asDriver(onErrorJustReturn: "")
            
            let submissionID = problemItem?.submissionID
            let titleOb: Driver<String> = .just(title).asDriver(onErrorJustReturn: "")
            let submissionIDOb: Observable<String> = (submissionID == nil) ? .just("") : .just(submissionID!)
            let submissionListGesture = problemPopUpView.submissionListGesture.map { _ in }
            let problemRefreshTap = problemPopUpView.problemRefreshTap
            let favoriteTap = problemPopUpView.favoriteTap
            
            let output = editorViewModel?.transform(input:.init(dismissAction: dissmissAction,
                                                                sendAction: sendSubmissionAction,
                                                                problemTitle: titleOb,
                                                                language: languageAction,
                                                                sourceCode: textChange, 
                                                                submissionID: submissionIDOb.asDriver(onErrorJustReturn: ""),
                                                                submissionListGesture: submissionListGesture,
                                                                problemRefreshTap: problemRefreshTap,
                                                                favoriteTap: favoriteTap))
            
            if let loadSourceCode = output?.loadSourceCode {
                languageAction
                    .distinctUntilChanged()
                    .withLatestFrom(loadSourceCode) { language, sourceCode in
                        return (language, sourceCode)
                    }
                    .drive(with: self, onNext: { vm, tuple  in
                        let (language, sourceCode) = tuple
                        vm.codeUITextView.languageBinding(language: language)
                        if !vm.sourceCodeState {
                            vm.codeUITextView.text = ""
                            vm.codeUITextView.text = sourceCode
                        } else {
                            vm.sourceCodeState = false
                        }
                    }).disposed(by: disposeBag)
            }
            
            output?.favoritProblem
                .drive(with: self, onNext: { view, flag in
                    view.problemPopUpView.heartButton.flag = flag
                }).disposed(by: disposeBag)
            
            favoriteTap
                .drive(with: self, onNext: { view, _ in
                    view.problemPopUpView.heartButton.flag.toggle()
                }).disposed(by: disposeBag)
            
            sendSubmissionAction
                .skip(1)
                .drive(with: self, onNext: { vc, _ in
                    vc.problemPopUpView.pageValue.accept(.result(nil))
                }).disposed(by: disposeBag)
            
            output?.solvedResult
                .drive(with: self,onNext: { vc, submission in
                    vc.problemPopUpView.pageValue.accept(.result(submission))
                }).disposed(by: disposeBag)
            
            output?.submissionListResult
                .drive(with: self, onNext: { vc, submissions in
                    vc.problemPopUpView.pageValue.accept(.resultList([]))
                }).disposed(by: disposeBag)
            
            output?.submitWaiting
                .emit(with: self, onNext: { vc, flag in
                    vc.problemPopUpView.submissionLoadingWating.accept(flag)
                }).disposed(by: disposeBag)
            
            output?.submissionListResult
                .drive(with: self, onNext: { vc, submissionList in
                    vc.problemPopUpView.pageValue.accept(.resultList([]))
                }).disposed(by: disposeBag)
            
            output?.problemRefreshResult
                .emit(with: self, onNext: { vc, state in
                    if case let .fail(error) = state {
                        vc.steps.accept(CodestackStep.toastMessage(" \(error) 불러오는데 실패"))
                    }
                    vc.problemPopUpView.problemState.accept(state)
                }).disposed(by: disposeBag)
            
            
            let tableView = problemPopUpView.submissionListView.tableView
            
            tableView.rx
                .setDelegate(self)
                .disposed(by: disposeBag)
            
            output?.submissionListResult
                .drive(with: self, onNext: { vc, value in
                    vc.problemPopUpView.submissionListView.addEmptyLayout(flag: value.isEmpty)
                }).disposed(by: disposeBag)
            
            output?.submissionListResult
                .drive(tableView.rx.items(cellIdentifier: HistoryCell.identifier,
                                          cellType: HistoryCell.self))
            { index, submission, cell in
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets.zero
                cell.backgroundColor = .clear
                cell.contentView.backgroundColor = .clear
                cell.onHistoryData.accept(submission)
                cell.onStatus.accept(submission.statusCode.convertSolveStatus())
            }.disposed(by: disposeBag)
        }
    }
    
    private func keyBoardLayoutManager(){
        let _ = KeyBoardManager.shared.getKeyBoardLifeCycle()
    }
    
}


//MARK: - 코드 문제 설명 뷰의 애니메이션 구현부
extension CodeEditorViewController{
    
    func showProblemDiscription(){
        problemPopUpView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(400)
        }
        numbersView.layer.setNeedsDisplay()
        self.codeUITextView.contentSize.height += problemPopUpView.bounds.height
    }
    
    //이거 먼저 선언
    func dismissProblemDiscription(button height: CGFloat = 44){
        problemPopUpView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(height).priority(.high)
        }
        numbersView.layer.setNeedsDisplay()
    }
}


//MARK: - TextView delegate
extension CodeEditorViewController: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}

extension CodeEditorViewController: NSLayoutManagerDelegate{
    func layoutManager(_ layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}

//MARK: - layout setting
extension CodeEditorViewController{
    
    private func layoutConfigure(){
        self.view.addSubview(problemPopUpView)
        self.view.addSubview(numberTextViewContainer)
        numberTextViewContainer.addSubview(codeUITextView)
        codeUITextView.addSubview(numbersView)
        
        
        let initialHeight = 44
        problemPopUpView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
//            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(60)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(initialHeight)
        }
        
        numberTextViewContainer.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
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
