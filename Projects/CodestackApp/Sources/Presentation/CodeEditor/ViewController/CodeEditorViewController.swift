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
import CommonUI
import ReactorKit
import SafariServices
import Domain


class CodeEditorViewController: UIViewController,
                                ReactorKit.View,
                                Stepper {
    
    typealias Reactor = CodeEditorReactor
    var steps = PublishRelay<Step>()
    private var editorViewModel: CodeEditorViewModel?
    var disposeBag = DisposeBag()
    var editorType: EditorTypeProtocol = ProblemSolveEditor()
    
    struct Dependency {
        var viewModel: CodeEditorViewModel
        var editorReactor: CodeEditorReactor
        var editorType: EditorTypeProtocol
    }
    
    static func create(with dependency: Dependency) -> CodeEditorViewController {
        let vc = CodeEditorViewController()
        vc.editorViewModel = dependency.viewModel
        vc.reactor = dependency.editorReactor
        vc.editorType = dependency.editorType
        vc.editorViewModel?.editorType = dependency.editorType
        vc.problemPopUpView.setLangueMenu(languages: dependency.editorType.getDefaultLanguage() )
        return vc
    }
    
    lazy var problemPopUpView: ProblemPopUpView = {
        let popView = ProblemPopUpView(frame: .zero,self)
        let html = editorType.problemContext
        popView.loadHTMLToWebView(html: html)
        popView.problemTitle.text = editorType.problemTitle
        return popView
    }()
    
    lazy var ediotrContainer = EditorContainerView().then { container in
        container.setDelegate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutConfigure()
        datainit()
        self.view.backgroundColor = .black
        self.view.bringSubviewToFront(problemPopUpView)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        binding()
        problemPopUpView.settingEditor(type: self.editorType)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if editorType.isProblemSolve() { problemPopUpView.show() }
    }
    
    /// TextView 의 무결성을 위한 Bool 값입니다.
    /// True일때는 최근에 제출했었던 source를 TextView에 적용합니다.
    private var sourceCodeState = false
    
    private var problemContext = BehaviorRelay<String>(value: "")
    
    func bind(reactor: CodeEditorReactor) {
        // TODO: Input View Reactor 킷으로 맵핑
//        problemPopUpView.sendSubmissionAction()
//            .map { "hello Send Button" }
//            .map(Reactor.Action.send)
//            .drive(reactor.action)
//            .disposed(by: disposeBag)
    }
    
    private func datainit() {
        if editorType.isOnlyEditor() {
            let codestackVO = editorType.getCodestackVO()
            sourceCodeState = true
            ediotrContainer.codeUITextView.text = codestackVO.sourceCode
            problemPopUpView.editorTitleField.text = codestackVO.name
            
        } else if editorType.isProblemSolve() {
            let problemItem = editorType.getProblemList()
            let sourceCode = problemItem.sourceCode
            ediotrContainer.codeUITextView.text = sourceCode
            sourceCodeState = true
            if let sourceCode, sourceCode.isEmpty { sourceCodeState = false }
            if let language = problemItem.seletedLanguage { problemPopUpView.languageRelay.accept(language) }
            if problemItem.sourceCode == nil { sourceCodeState = false }
            if let context = problemItem.contenxt { problemContext.accept(context) }
        }
    }
    
    private func inputSubmissionID() -> Driver<String> {
        let submissionID = editorType.getSubmissionID()
        return Observable
            .just(submissionID)
            .asDriverJust()
    }
    
    private func inputSubmissionAction() -> Driver<String> {
        let id = editorType.problemID
        return problemPopUpView
            .sendSubmissionAction()
            .map { _ in "\(id)" }
            .startWith("\(id)")
            .asDriverJust()
    }
    
    private func inputTextChangeAction() -> Driver<String> {
        ediotrContainer.codeUITextView.rx.text
            .debounce(.milliseconds(300),
                      scheduler: MainScheduler.instance)
            .compactMap { $0 }
            .asDriverJust()
    }
    
    private func binding() {
        let output = inputBinding()
        outputBinding(output)
    }
    
    private func inputBinding() -> CodeEditorViewModel.Output? {
        let title                 : String             = editorType.problemTitle
        let sendSubmissionAction  : Driver<String>     = inputSubmissionAction()
        let submissionIDOb        : Driver<String>     = inputSubmissionID()
        let textChange            : Driver<String>     = inputTextChangeAction()
        let languageAction        : Driver<LanguageVO> = problemPopUpView.languageAction()
        let titleOb               : Driver<String>     = Driver.just(title)
        let submissionListGesture : Driver<Void>       = problemPopUpView.submissionListGesture.map { _ in }
        let problemRefreshTap     : Driver<Void>       = problemPopUpView.problemRefreshTap
        let favoriteTap           : Driver<Bool>       = problemPopUpView.favoriteTap
        let problemContext        : Signal<String>     = problemContext.asSignalJust()
        let dissmissAction        : Driver<Void>       = problemPopUpView.dissmissAction()
        let editorTitleField      : Driver<String>     = problemPopUpView.editorTitleField.rx.text.orEmpty.asDriver()
        let linkDetector          : Signal<String>     = problemPopUpView.linkDetector.asSignalJust()
        let problemVO             : Signal<ProblemVO>  = Signal.just(editorType.getProblemVO())
        
        let output = editorViewModel?
            .transform(input:.init(viewDidLoad: OB.justVoid(),
                                   problemVO: problemVO,
                                   problemContext: problemContext,
                                   dismissAction: dissmissAction,
                                   sendAction: sendSubmissionAction,
                                   problemTitle: titleOb,
                                   language: languageAction,
                                   sourceCode: textChange,
                                   submissionID: submissionIDOb,
                                   submissionListGesture: submissionListGesture,
                                   problemRefreshTap: problemRefreshTap,
                                   favoriteTap: favoriteTap,
                                   sourceCodenameWhenEditorOnly: editorTitleField.asDriver()))
        
        viewBinding(language: languageAction,output)
        viewBinding(favor: favoriteTap,
                    action: sendSubmissionAction,
                    linkDetector: linkDetector)
        submissionHistoryViewBinding()
        
        return output
    }
    
    func outputBinding(_ output: CodeEditorViewModel.Output?) {
        output?.laguageBinding
            .drive(with: self, onNext: { vc, langVO in
                vc.problemPopUpView.languageRelay.accept(langVO)
            }).disposed(by: disposeBag)
        
        output?.favoritProblem
            .drive(with: self, onNext: { view, flag in
                view.problemPopUpView.heartButton.flag = flag
            }).disposed(by: disposeBag)
        
        output?.solvedResult
            .drive(with: self, onNext: { vc, submission in
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
            .skip(1)
            .emit(with: self, onNext: { vc, state in
                if case let .fail(error) = state {
                    vc.steps.accept(CodestackStep.toastMessage(" \(error) 불러오는데 실패"))
                }
                vc.problemPopUpView.problemState.accept(state)
                
            }).disposed(by: disposeBag)
        
        let tableView = problemPopUpView.submissionListView.tableView
        
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
            cell.onStatus.accept(submission.statusCode)
        }.disposed(by: disposeBag)
    }
    
    private func submissionHistoryViewBinding() {
        let submissionHistoryTapped = problemPopUpView.submissionListView.tableView.rx
            .modelSelected(SubmissionVO.self)
            .asObservable()
        
        submissionHistoryTapped
            .map(\.language)
            .bind(to: problemPopUpView.languageRelay)
            .disposed(by: disposeBag)
            
        submissionHistoryTapped
            .map(\.sourceCode)
            .bind(to: ediotrContainer.codeUITextView.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func viewBinding(language action: Driver<LanguageVO>, _ output: CodeEditorViewModel.Output?) {
        // MARK: View Action
        if let loadSourceCode = output?.loadSourceCode {
            action
                .distinctUntilChanged()
                .withLatestFrom(loadSourceCode) { language, sourceCode in
                    return (language, sourceCode)
                }
                .drive(with: self, onNext: { vm, tuple  in
                    let (language, sourceCode) = tuple
                    vm.ediotrContainer.codeUITextView.languageBinding(language: language)
                    if !vm.sourceCodeState {
                        vm.ediotrContainer.codeUITextView.text = ""
                        vm.ediotrContainer.codeUITextView.text = sourceCode
                    } else {
                        vm.sourceCodeState = false
                    }
                }).disposed(by: disposeBag)
        }
    }
    
    private func viewBinding(favor favoriteTap: Driver<Bool>,
                             action sendSubmission: Driver<String>,
                             linkDetector: Signal<String>) {
        
        favoriteTap.drive(with: self, onNext: { view, _ in
            view.problemPopUpView.heartButton.flag.toggle()
        }).disposed(by: disposeBag)
        
        sendSubmission
            .skip(1)
            .drive(with: self, onNext: { vc, _ in
                if vc.editorType.isProblemSolve() {
                    vc.problemPopUpView.pageValue.accept(.result(nil))
                }
            }).disposed(by: disposeBag)

        linkDetector.compactMap { URL(string: $0) }
            .emit(with: self, onNext: { vc, url in
                let sf = SFSafariViewController(url: url)
                sf.delegate = vc
                vc.navigationController?.pushViewController(sf, animated: false)
            }).disposed(by: disposeBag)
    }
    
    private func keyBoardLayoutManager(){
        let _ = KeyBoardManager.shared.getKeyBoardLifeCycle()
    }
    
}


//MARK: - 코드 문제 설명 뷰의 애니메이션 구현부
extension CodeEditorViewController {
    func showProblemDiscription() {
        problemPopUpView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(400)
        }
        ediotrContainer.numbersView.layer.setNeedsDisplay()
        ediotrContainer.codeUITextView.contentSize.height += problemPopUpView.bounds.height
    }
    
    //이거 먼저 선언
    func dismissProblemDiscription(button height: CGFloat = 44){
        problemPopUpView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(height).priority(.high)
        }
        ediotrContainer.numbersView.layer.setNeedsDisplay()
    }
}

//MARK: - layout setting
extension CodeEditorViewController {
    private func layoutConfigure() {
        self.view.addSubview(problemPopUpView)
        self.view.addSubview(ediotrContainer)

        let initialHeight = 44
        
        problemPopUpView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(initialHeight)
        }
        
        ediotrContainer.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(self.view.snp.height).priority(.low)
        }
        
        ediotrContainer.codeUITextView.snp.remakeConstraints { make in
            make.top.equalTo(problemPopUpView.snp.bottom)
            make.trailing.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
    }
}
