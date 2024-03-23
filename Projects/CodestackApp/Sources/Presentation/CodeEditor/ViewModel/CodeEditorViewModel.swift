//
//  CodeEditorViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/04.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa
import Apollo
import Global
import Domain

enum FavoriteError: Error {
    case error
}

enum FetchError: Error {
    case fetchError
}

protocol CodeEditorViewModelType: ViewModelType { }

final class CodeEditorViewModel: CodeEditorViewModelType {
    
    typealias SourceCode = String
    
    struct Input {
        var viewDidLoad:           Signal<Void>
        var problemVO:             Signal<ProblemVO>
        var problemContext:        Signal<String>
        var dismissAction:         Driver<Void>
        var sendAction:            Driver<ProblemID>
        var problemTitle:          Driver<String>
        var language:              Driver<LanguageVO>
        var sourceCode:            Driver<SourceCode>
        var submissionID:          Driver<SubmissionID>
        var submissionListGesture: Driver<Void>
        var problemRefreshTap:     Driver<Void>
        var favoriteTap:           Driver<Bool>
        
        // 문제 풀기가 아닌 Editor Only Mode일 경우 받는 Input
        var sourceCodenameWhenEditorOnly: Driver<String>
    }
    
    struct Output {
        var solvedResult:          Driver<SubmissionVO>
        var submissionListResult:  Driver<[SubmissionVO]>
        var submitWaiting:         Signal<Bool>
        var submissionListWaiting: Signal<Bool>
        var problemRefreshResult:  Signal<ProblemState>
        var favoritProblem:        Driver<Bool>
        var loadSourceCode:        Driver<SourceCode>
        var laguageBinding:        Driver<LanguageVO>
    }
    
    struct Dependency {
        let homeViewModel:     any HomeViewModelType
        let historyViewModel:  any HistoryViewModelType
        let submissionUseCase: SubmissionUseCase
        let stepper:           CodeEditorStepper
        let codeuseCase:       CodeUsecase
        let jzuseCase:         JZUsecase
    }
    
    init(dependency: Dependency) {
        self.homeViewModel     = dependency.homeViewModel
        self.historyViewModel  = dependency.historyViewModel
        self.submissionUseCase = dependency.submissionUseCase
        self.stepper           = dependency.stepper
        self.codeuseCase       = dependency.codeuseCase
        self.jzuseCase         = dependency.jzuseCase
        
        /// 프로퍼티로 추후 초기화 진행
        self.editorType = DefaultEditor()
    }
    
    weak var stepper:           CodeEditorStepper?
    weak var homeViewModel:     (any HomeViewModelType)?
    weak var historyViewModel:  (any HistoryViewModelType)?
    var editorType:             EditorTypeProtocol
    
    private var submissionUseCase:  SubmissionUseCase
    private var codeuseCase:        CodeUsecase
    private var jzuseCase:          JZUsecase
    
    private var disposeBag = DisposeBag()
    
    private var languageRelay           = BehaviorRelay<LanguageVO>(value: LanguageVO.default)
    private var sourceCodeRelay         = BehaviorRelay<SourceCode>(value: "")
    private var sendProblemModel        = BehaviorRelay<SendProblemModel>(value: .default)
    private var sourceCodeCache: [String: SourceCode] = [:]
    private var sourceCodenameWhenEditorOnly = BehaviorRelay<String>(value: "제목없음")
    
    // MARK: Output
    private var solvedResult           = PublishRelay<SubmissionVO>()
    private var submitWaiting          = BehaviorRelay<Bool>(value: false)
    private var submissionListResult   = BehaviorRelay<[SubmissionVO]>(value: [])
    private var submissionListWaiting  = BehaviorRelay<Bool>(value: false)
    private var favoriteProblem        = BehaviorRelay<Bool>(value: false)
    private var tempSaveFlag           = BehaviorRelay<Bool>(value: false)
    private var lanugageFirstBinding   = BehaviorRelay(value: LanguageVO.default)
    private(set) var problemRefreshResult = BehaviorRelay<ProblemState>(value: .fetched(.sample))
    
    enum ProblemState {
        case fetched(ProblemVO)
        case fail(Error)
    }
    
    func transform(input: Input) -> Output {
        
        let sendTrigger = input.sendAction.asSignal(onErrorJustReturn: "")
        
        makeSendModelUsing(input: input)
        problemIsValidStateBinding(problemContext: input.problemContext)
        languageAction(action: input.language)
        sourceCodeAction(action: input.sourceCode)
        
        if editorType.isOnlyEditor() {
            input.dismissAction.drive(with: self, onNext: { vm, step in
                vm.stepper?.steps.accept(CodestackStep.problemComplete)
            }).disposed(by: disposeBag)
            
            input.sourceCodenameWhenEditorOnly
                .drive(sourceCodenameWhenEditorOnly)
                .disposed(by: disposeBag)
            
            lanugageFirstBinding.accept(editorType.getSeletedLanguage())
            
            sendActionWhenEditorMode(action: sendTrigger)
            
        } else {
            problemBinding(input: input.problemVO)
            dissmissAction(action: input.dismissAction)
            sendAction(action: sendTrigger)
            viewDidLoadAction(action: input.viewDidLoad, problemID: input.sendAction)
            favoriteProblemAction(action: input.favoriteTap)
            problemRefreshAction(action: input.problemRefreshTap)
            loadSubmissionList(action: input.submissionListGesture, probelmID: input.sendAction)
        }
        
        return Output(
            solvedResult:          solvedResult.asDriver(onErrorJustReturn: .sample),
            submissionListResult:  submissionListResult.asDriver(),
            submitWaiting:         submitWaiting.asSignal(onErrorJustReturn: false),
            submissionListWaiting: submissionListWaiting.asSignal(onErrorJustReturn: false),
            problemRefreshResult:  problemRefreshResult.asSignal(onErrorJustReturn: .fetched(.sample)),
            favoritProblem:        favoriteProblem.asDriver(),
            loadSourceCode:        sourceCodeRelay.asDriver(),
            laguageBinding:        lanugageFirstBinding.asDriver()
        )
    }
    
    private func problemBinding(input problemVO: Signal<ProblemVO>) {
        problemVO
            .map { $0.isNotMock ? .fetched($0) : .fail(FetchError.fetchError) }
            .emit(to: problemRefreshResult)
            .disposed(by: disposeBag)
    }
    
    
    /// ViewController에서 문제(context) 를 받아서 현재 문제가 정상적으로 Load 되어있는지 판별하는 함수입니다.
    private func problemIsValidStateBinding(problemContext: Signal<String>) {
        problemContext
            .emit(with: self, onNext: { vm, context in
                let flag = context.isEmpty || context.count < 2
                if flag { return vm.problemRefreshResult.accept(.fail(FetchError.fetchError)) }
                vm.problemRefreshResult.accept(.fetched(.sample))
            }).disposed(by: disposeBag)
    }
    
    private func makeSendModelUsing(input: Input) {
        let combine = Observable.combineLatest(languageRelay.asObservable(),
                                               input.problemTitle.asObservable(),
                                               sourceCodeRelay.asObservable(),
                                               input.sendAction.asObservable(),
                                               input.submissionID.asObservable())
        // TODO: distilt Until Change 대응
        combine
            .distinctUntilChanged { $0 == $1 }
            .debounce(.milliseconds(400), scheduler: MainScheduler.instance)
            .map { value in SendProblemModel(tuple: value) }
            .subscribe(with: self, onNext: { vm, values in
                vm.sendProblemModel.accept(values)
            }).disposed(by: disposeBag)
    }
    
    private func viewDidLoadAction(action: Signal<Void>, problemID: Driver<ProblemID>) {
        
        let prID = problemID.asObservable().take(1)
        
        prID
            .withUnretained(self)
            .flatMap { vm, prID in vm.submissionUseCase.fetchRecent(id: prID) }
            .subscribe(with: self, onNext: { vm , value in
                vm.sourceCodeCache[value.language.name] = value.sourceCode
                vm.sourceCodeRelay.accept(value.sourceCode)
                vm.lanugageFirstBinding.accept(value.language)
            }).disposed(by: disposeBag)
        
        action
            .asObservable()
            .flatMap { _ in prID }
            .withUnretained(self)
            .flatMapFirst { vm, problemID in
                return vm.submissionUseCase.fetchIsFavorite(problemID: problemID)
            }
            .filter { $0 }
            .bind(to: favoriteProblem)
            .disposed(by: disposeBag)
    }
    
    private func favoriteProblemAction(action: Driver<Bool>) {
        action
            .asObservable()
            .throttle(.milliseconds(400), latest: true, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .flatMapLatest { vm, flag in
                let model = vm.sendProblemModel.take(1)
                    .asObservable()
                    .map { $0.makeFavoirtProblem()}
                
                let action = model.flatMapLatest { model in
                    vm.submissionUseCase.updateFavoritProblem(model: model, flag: flag)
                }
                return Observable.zip(action, model)
            }
            .subscribe(with: self, onNext: { vm, value in
                let (result, model) = value
                switch result {
                case .success(let flag):
                    vm.favoriteProblem.accept(flag)
                    let submissionVO = model.toSubmissionVO()
                    // ADD OR DELETE Submission VO in history ViewModel
                    let history = vm.historyViewModel
                    flag ? history?.sendSubmission.accept(submissionVO) : history?.deleteSubmission.accept(submissionVO)
                    
                case .failure(_):
                    vm.favoriteProblem.accept(false)
                }
            }).disposed(by: disposeBag)
    }
    
    private func problemRefreshAction(action: Driver<Void>) {
        action
            .asObservable()
            .withUnretained(self)
            .flatMap { vm, _ -> Observable<SendProblemModel> in
                vm.sendProblemModel.take(1).asObservable()
            }
            .delay(.milliseconds(800), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .flatMap { vm, model -> Observable<State<ProblemVO>> in
                vm.submissionUseCase.fetchProblem(id: model.problemID)
            }
            .subscribe(with: self, onNext: { vm, result in
                switch result {
                case .success(let problem):
                    let context = problem.context
                    let flag = context.isEmpty || context.count < 2
                    if flag { return vm.problemRefreshResult.accept(.fail(FetchError.fetchError)) }
                    vm.problemRefreshResult.accept(.fetched(problem))
                case .failure(let error):
                    vm.problemRefreshResult.accept(.fail(error))
                }
            }).disposed(by: disposeBag)
    }
    
    //MARK: - Action Binding FUNC
    private func dissmissAction(action: Driver<Void>) {
        // MARK: 아무것도 변경하지 않았으면 임시저장은 하지 말아야 함..
        action
            .asObservable()
            .withUnretained(self)
            .flatMapFirst { vm, _ in vm.tempSaveFlag.take(1).asObservable() }
            .withUnretained(self)
            .filter { vm, isTempSave in
                if !isTempSave { vm.stepper?.steps.accept(CodestackStep.problemComplete) }
                return isTempSave
            }
            .withLatestFrom(sendProblemModel.asObservable()) { $1 }
            .withUnretained(self)
            .flatMap { vm, sendModel in
                let domainModel = sendModel.toTempDomain()
                return vm.updateSubmissionAction(domainModel)
            }
            .subscribe(with: self, onNext: { vm, value in
                vm.stepper?.steps.accept(CodestackStep.problemComplete)
            },onError: { vm, _ in
                vm.stepper?.steps.accept(CodestackStep.problemComplete)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateSubmissionAction(_ domainModel: SubmissionVO) -> Observable<Bool> {
        submissionUseCase
            .updateSubmissionAction(model: domainModel)
            .do(onNext: { [weak self] flag in
                if flag { //FIXME: 변경 사항이 있을때 즉, 업데이트 가 이루어졌을때 전달
                    self?.homeViewModel?.sendSubmission.accept(domainModel)
                    self?.historyViewModel?.sendSubmission.accept(domainModel)
                }
            })
    }
    
    private func sourceCodeAction(action: Driver<SourceCode>) {
        action.asObservable().skip(1)
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { _ in true }
            .bind(to: tempSaveFlag)
            .disposed(by: disposeBag)
        
        action
            .skip(1)
            .asObservable()
            .withUnretained(self)
            .flatMap { vm, sourceCode -> Observable<(LanguageVO, SourceCode)>  in
                Observable.zip(vm.languageRelay.take(1), Observable.just(sourceCode))
            }
            .asDriver(onErrorJustReturn: (LanguageVO.default, ""))
            .drive(with: self, onNext: { vm, tuple in
                let (language, sourceCode) = tuple
                vm.sourceCodeCache[language.name] = sourceCode
                vm.sourceCodeRelay.accept(sourceCode)
            }).disposed(by: disposeBag)
    }
    
    private func languageAction(action: Driver<LanguageVO>) {
        action
            .distinctUntilChanged()
            .map { [weak self] language -> (LanguageVO, String?) in
                if let sourceCode = self?.sourceCodeCache[language.name] {
                    return (language, sourceCode)
                }
                let load = self?.loadSourceCodeBy(language: language)
                return (language, load)
            }
            .drive(with: self, onNext: { vm, tuple in
                let (lanuguage, sourceCode) = tuple
                vm.languageRelay.accept(lanuguage)
                if let sourceCode {
                    vm.sourceCodeRelay.accept(sourceCode)
                }
            }).disposed(by: disposeBag)
    }
    
    private func loadSubmissionList(action: Driver<Void>, probelmID: Driver<ProblemID>) {
        action
            .asObservable()
            .take(1)
            .flatMap { _ in probelmID.asObservable().take(1) }
            .flatMap { [weak self] (id) -> Observable<Result<[SubmissionVO], Error>> in
                guard let self else { return .just(.success([])) }
                return self.submissionUseCase
                    .fetchProblemSubmissionHistory(id: id, state: .temp)
            }
            .map { result in
                if case let .success(submissions) = result {
                    return submissions.sortByDate()
                }
                return []
            }
            .subscribe(with: self, onNext: { vm, submissions in
                vm.submissionListResult.accept(submissions)
            }).disposed(by: disposeBag)
    }
    
    
    func sendActionWhenEditorMode(action: Signal<ProblemID>) {
        action
            .skip(1)
            .withUnretained(self)
            .do(onNext: { vm, _ in vm.submitWaiting.accept(true) })
            .delay(.seconds(1))
            .withLatestFrom(sendProblemModel.asSignal(onErrorJustReturn: .default)) { $1 }
            .withUnretained(self)
            .asObservable()
            .flatMapLatest { vm, model -> Observable<State<CodestackVO>> in
                vm.sourceCodenameWhenEditorOnly
                    .take(1)
                    .flatMapLatest { title in
                        let id = model.submissionID
                        let saveModel =  model.toCodestackDomain(title)
                        return vm.codeuseCase.codeSaveAction(id: id, codestackVO: saveModel)
                    }
            }
            .withUnretained(self)
            .do(onNext: { vm, _ in vm.submitWaiting.accept(false) })
            .subscribe(onNext: { vm, submission in
                switch submission {
                case .success:
                    let step = CodestackStep.toastV2Message(.success, "저장이 성공적으로 완료되었습니다.")
                    vm.stepper?.steps.accept(step)
                case .failure:
                    vm.submitWaiting.accept(false)
                }
            }).disposed(by: disposeBag)
        return
    }
    
    /// 문제제출 메소드
    /// - Parameter action: 문제 id를 관찰하고 있는 Driver
    func sendAction(action: Signal<ProblemID>) {
        //            action
        //                .skip(1)
        //                .asObservable()
        //                .withUnretained(self)
        //                .flatMap { vm, _ in vm.makeSendSubmissionQuery() }
        //                .withUnretained(self)
        //                .do(onNext: { vm, _ in vm.submitWaiting.accept(true) })
        //                .flatMapLatest { vm, model in
        //                    let query = JZQuery(code: model.sourceCode,
        //                                        language: model.language,
        //                                        problem: model.toProblemIdentity(),
        //                                        nickname: model.userName)
        //                    return vm.jzuseCase.submissionPerform(query: query)
        //                }.subscribe(with: self, onNext: { vm, result in
        //
        //                })
        
        action
            .skip(1)
            .asObservable()
            .withUnretained(self)
            .flatMap { vm, _ in vm.makeSendSubmissionQuery() }
            .withUnretained(self)
            .do(onNext: { vm, _ in vm.submitWaiting.accept(true) })
            .flatMapLatest { vm, model in
                let (sendModel, problemVO) = model
                let query = JZQuery(code: sendModel.sourceCode,
                                    language: sendModel.language,
                                    problem: problemVO,
                                    nickname: sendModel.userName)
                
                return vm.jzuseCase.submissionPerform(query: query)
            }.subscribe(with: self, onNext: { vm, result in
                vm.viewErrorInteractorAction(result)
                vm.submitWaiting.accept(false)
            })
            .disposed(by: disposeBag)
        //                .skip(1)
        //                .asObservable()
        //                .withUnretained(self)
        //                .flatMap { vm, _ in vm.isProblemValideState() }
        //                .withLatestFrom(sendProblemModel.asObservable()) { $1 }
        //                .withUnretained(self)
        //                .do(onNext: { vm, _ in vm.submitWaiting.accept(true) })
        //                .delay(.seconds(1), scheduler: MainScheduler.instance)
        //                .do(onError: { [weak self] _ in self?.submitWaiting.accept(false) })
        //                .flatMap { vm, model in vm.submissionUseCase.submitSubmissionAction(model: model.toTempDomain())}
        //                .observe(on: MainScheduler.instance)
        //                .subscribe(with: self, onNext: { vm, submission in
        //                    switch submission {
        //                    case .success(let submission):
        //                        vm.sendActionResultBinding(submission)
        //                    case .failure(let err):
        //                        vm.viewErrorInteractorAction(err)
        //                        vm.submitWaiting.accept(false)
        //                    }
        //                })
        //                .disposed(by: disposeBag)
    }
    
    private func loadSourceCodeBy(language: LanguageVO) -> String {
        var name = language.name
        if language.name == "Node" ||
            language.name == "Node.js" {
            name = "nodejs"
        } else {
            name = language.name
        }
        
        guard let path = Bundle.main.path(forResource: "\(name.lowercased())", ofType: "txt"),
              let strings = try? String(contentsOfFile: path)
        else { return "" }
        
        return strings
    }
    
    private func makeSendSubmissionQuery() -> Observable<(SendProblemModel, ProblemVO)> {
        isProblemValideState()
            .withLatestFrom(sendProblemModel.asObservable()) { state, model in
                if case let .fetched(problemVO) = state {
                    return (model, problemVO)
                } else {
                    //MARK: 실행 안되는 부분입니다.
                    return (model, .sample)
                }
            }
    }
    
    private func isProblemValideState() -> Observable<ProblemState> {
        self.problemRefreshResult
            .take(1)
            .asObservable()
            .filter { state in
                /// Fetch 에 성공인지, 실패인지 판별
                if case .fail = state {
                    self.stepper?
                        .steps
                        .accept(CodestackStep.toastMessage("문제의 정보를 가져오는데 실패하였습니다"))
                    return false
                }
                return true
            }
    }
    
    private func sendActionResultBinding(_ submission: SubmissionVO) {
        // MARK: ViewInteractor Action flow
        // 1. submit Wating: indicator false 로변경
        // 2. solvedResult 제출 결과 반영
        // 3. SubmissionListResult에 리스트 반영
        // 4. tempSaveFlag 임시 저장 불가능 하게 변경
        // 5. Home, History ViewModel 에 전달 -> Domain Output Global 로 설정 ?
        solvedResult.accept(submission)
        
        _ = Observable.just(submission)
            .withLatestFrom(submissionListResult) { new , original -> [SubmissionVO] in
                return [new] + original
            }
            .bind(to: submissionListResult)
        
        tempSaveFlag.accept(false)
        
        self.homeViewModel?.sendSubmission.accept(submission)
        self.historyViewModel?.sendSubmission.accept(submission)
    }
}

extension CodeEditorViewModel {
    private func viewErrorInteractorAction(_ result: State<SubmissionVO>) {
        // FIXME: TOKEN SERVICE ERROR 변경해야됌
        // submissionUseCase.mappingDomain(error)
        switch result {
        case let .success(submission):
            self.sendActionResultBinding(submission)
            
        case let .failure(error) where (error as? Domain.TokenError) == .unowned:
            self.stepper?.steps.accept(CodestackStep.toastMessage("서버에 response가 오지 않습니다"))
            
        case let .failure(error) where (error as? Domain.TokenError) == .unauthorized:
            self.stepper?.steps.accept(CodestackStep.loginNeeded)
            
            
        case let .failure(error) where (error as? Domain.SendError) == .isEqualSubmission:
            self.stepper?.steps.accept(CodestackStep.toastMessage("같은 내용입니다"))
                
        case let .failure(error) where (error as? Domain.JZError) == .exceededUsage:
            self.stepper?.steps.accept(CodestackStep.toastV2Message(.error, "사용량을 초과하였습니다. 관리자에게 문의해주세요"))
            
            
        case let .failure(error) where (error as? Domain.JZError) == .none:
            self.stepper?.steps.accept(CodestackStep.toastV2Message(.error, "잠시후에 다시 시도해 주세요"))
            
        default:
            self.stepper?.steps.accept(CodestackStep.toastV2Message(.error, "알수 없는 에러가 발생하였습니다."))
        }
    }
}
