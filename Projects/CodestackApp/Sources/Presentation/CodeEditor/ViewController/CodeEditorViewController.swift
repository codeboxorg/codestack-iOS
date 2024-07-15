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
    
    var disposeBag = DisposeBag()
    var editorType: EditorTypeProtocol = ProblemSolveEditor()
    
    private var editorViewModel: CodeEditorViewModel!
    private(set) lazy var binderProvider = BinderProvider(self)
    private(set) lazy var actionProvider = ActionProvider(self)
    
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
        vc.actionProvider.setLangueMenu(languages: dependency.editorType.getDefaultLanguage() )
        return vc
    }
    
    lazy var _problemPopUpView: DynamicWrapperView<ProblemPopUpView> = {
        let popView = DynamicWrapperView(ProblemPopUpView(frame: .zero,self))
        let html = editorType.problemContext
        popView.view.loadHTMLToWebView(html: html)
        popView.view.problemTitle.text = editorType.problemTitle
        return popView
    }()
    
    var problemPopUpView: ProblemPopUpView {
        _problemPopUpView.view
    }
    
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
    var sourceCodeState = false
    
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
            if let language = problemItem.seletedLanguage {
                // TODO: Fix
                // problemPopUpView.languageRelay.accept(language)
                binderProvider.languageBinder.onNext(language.name)
            }
            if problemItem.sourceCode == nil { sourceCodeState = false }
            if let context = problemItem.contenxt {
                problemContext.accept(context)
            }
        }
    }
    
    private func binding() {
        let output = inputBinding()
        actionProvider.actionBinding()
        submissionHistoryViewBinding()
        outputBinding(output)
    }
    
    /// 언어 모델
    private func inputBinding() -> CodeEditorViewModel.Output? {
        let title                : String             = editorType.problemTitle
        let sendSubmissionAction : Driver<String>     = actionProvider.sendSubmissionAction(editorType.problemID)//inputSubmissionAction()
        let submissionIDOb       : Driver<String>     = actionProvider._submissionID
        let textChange           : Driver<String>     = actionProvider._inputTextChangeAction
        let languageAction       : Driver<LanguageVO> = actionProvider.$dynamicLanguage.asDriver(onErrorJustReturn: .default)
        let titleOb              : Driver<String>     = Driver.just(title)
        let submissionListGesture: Driver<Void>       = actionProvider._submissionListGesture
        let problemRefreshTap    : Driver<Void>       = actionProvider._$refreshTap
        let favoriteTap          : Driver<Bool>       = actionProvider._$favoriteTap
        let problemContext       : Signal<String>     = problemContext.asSignalJust()
        let dissmissAction       : Driver<Void>       = actionProvider._backButtonTap
        let editorTitleField     : Driver<String>     = actionProvider._editorTitleFieldChange
        let problemVO            : Signal<ProblemVO>  = Signal.just(editorType.getProblemVO())
        
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
        
        if let loadSourceCode = output?.loadSourceCode {
            actionProvider._languageDriver
                .distinctUntilChanged()
                .withLatestFrom(loadSourceCode) { language, sourceCode in
                    return (language, sourceCode)
                }
                .drive(binderProvider.sourceCodeBinder)
                .disposed(by: disposeBag)
        }
        
        return output
    }
    
    private func outputBinding(_ output: CodeEditorViewModel.Output?) {
        
        output?.laguageBinding
            .map(\.name)
            .drive(binderProvider.languageBinder)
            .disposed(by: disposeBag)
        
        output?.favoritProblem
            .drive(with: self, onNext: { view, flag in
                view.problemPopUpView.heartButton.flag = flag
            }).disposed(by: disposeBag)
        
        output?.solvedResult
            .map(SolveResultType.result)
            .drive(binderProvider.problemPopUpViewPageBinder)
            .disposed(by: disposeBag)
        
        output?.submitWaiting
            .emit(to: binderProvider.submissionLoadingBinder)
            .disposed(by: disposeBag)
        
        output?.problemRefreshResult
            .skip(1)
            .emit(
                with: self,
                onNext: { vc, state in
                    if case let .fail(error) = state {
                        vc.steps.accept(CodestackStep.toastMessage(" \(error) 불러오는데 실패"))
                    }
                    vc.binderProvider.problemStateBinder.onNext(state)
                }
            )
            .disposed(by: disposeBag)
        
        let tableView = problemPopUpView.submissionListView.tableView
        
        
        output?.submissionListResult
            .map { _ in SolveResultType.resultList([]) }
            .drive(binderProvider.problemPopUpViewPageBinder)
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
            cell.onStatus.accept(submission.statusCode)
        }.disposed(by: disposeBag)
    }
    
    // TODO: As is = TextView Text 교체 , to be = New View Contruct
    private func submissionHistoryViewBinding() {
        let submissionHistoryTapped = problemPopUpView.submissionListView.tableView.rx
            .modelSelected(SubmissionVO.self)
            .asObservable()
        
        submissionHistoryTapped
            .map(\.language.name)
            .bind(to: binderProvider.languageBinder)
            .disposed(by: disposeBag)
            
        submissionHistoryTapped
            .map(\.sourceCode)
            .bind(to: ediotrContainer.codeUITextView.rx.text)
            .disposed(by: disposeBag)
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
