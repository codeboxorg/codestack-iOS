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
        var viewDidLoad: Signal<Void>
        var problemContext: Signal<String>
        var dismissAction: Driver<Void>
        var sendAction: Driver<ProblemID>
        var problemTitle: Driver<String>
        var language: Driver<LanguageVO>
        var sourceCode: Driver<SourceCode>
        var submissionID: Driver<SubmissionID>
        var submissionListGesture: Driver<Void>
        var problemRefreshTap: Driver<Void>
        var favoriteTap: Driver<Bool>
    }
    
    struct Output {
        var solvedResult: Driver<SubmissionVO>
        var submissionListResult: Driver<[SubmissionVO]>
        var submitWaiting: Signal<Bool>
        var submissionListWaiting: Signal<Bool>
        var problemRefreshResult: Signal<ProblemState>
        var favoritProblem: Driver<Bool>
        var loadSourceCode: Driver<SourceCode>
        var laguageBinding: Driver<LanguageVO>
    }
    
    struct Dependency {
        let homeViewModel: any HomeViewModelType
        let historyViewModel: any HistoryViewModelType
        let submissionUseCase: SubmissionUseCase
        let stepper: CodeEditorStepper
    }
    
    init(dependency: Dependency) {
        self.homeViewModel = dependency.homeViewModel
        self.historyViewModel = dependency.historyViewModel
        self.submissionUseCase = dependency.submissionUseCase
        self.stepper = dependency.stepper
    }
    
    weak var stepper: CodeEditorStepper?
    weak var homeViewModel: (any HomeViewModelType)?
    weak var historyViewModel: (any HistoryViewModelType)?
    private var submissionUseCase: SubmissionUseCase
    
    private var disposeBag = DisposeBag()
    
    private var languageRelay = BehaviorRelay<LanguageVO>(value: LanguageVO.default)
    private var sourceCodeRelay = BehaviorRelay<SourceCode>(value: "")
    private var sendProblemModel = BehaviorRelay<SendProblemModel>(value: .default)
    private var sourceCodeCache: [String: SourceCode] = [:]

    // MARK: Output
    private var solvedResult = PublishRelay<SubmissionVO>()
    private var submitWaiting = BehaviorRelay<Bool>(value: false)
    private var submissionListResult = BehaviorRelay<[SubmissionVO]>(value: [])
    private var submissionListWaiting = BehaviorRelay<Bool>(value: false)
    private var favoriteProblem = BehaviorRelay<Bool>(value: false)
    private var tempSaveFlag = BehaviorRelay<Bool>(value: false)
    private var lanugageFirstBinding = BehaviorRelay(value: LanguageVO.default)
    
    deinit {
         Log.debug("codeEditorViewModel Deinit")
    }
    
    enum ProblemState {
        case fetched(ProblemVO)
        case fail(Error)
    }
    
    private var problemRefreshResult = BehaviorRelay<ProblemState>(value: .fetched(.sample))
    
    func transform(input: Input) -> Output {
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
        
        input.problemContext
            .emit(with: self, onNext: { vm, context in
                let flag = context.isEmpty || context.count < 2
                if flag { return vm.problemRefreshResult.accept(.fail(FetchError.fetchError)) }
                vm.problemRefreshResult.accept(.fetched(.sample))
            }).disposed(by: disposeBag)
        
        viewDidLoadAction(action: input.viewDidLoad, problemID: input.sendAction)
        favoriteProblemAction(action: input.favoriteTap)
        problemRefreshAction(action: input.problemRefreshTap)
        dissmissAction(action: input.dismissAction, problemID: input.sendAction)
        languageAction(action: input.language)
        sourceCodeAction(action: input.sourceCode)
        loadSubmissionList(action: input.submissionListGesture, probelmID: input.sendAction)
        
        sendAction(action: input.sendAction.asSignal(onErrorJustReturn: ""))
        
        return Output(
            solvedResult: solvedResult.asDriver(onErrorJustReturn: .sample),
            submissionListResult: submissionListResult.asDriver(),
            submitWaiting: submitWaiting.asSignal(onErrorJustReturn: false),
            submissionListWaiting: submissionListWaiting.asSignal(onErrorJustReturn: false),
            problemRefreshResult: problemRefreshResult.asSignal(onErrorJustReturn: .fetched(.sample)),
            favoritProblem: favoriteProblem.asDriver(),
            loadSourceCode: sourceCodeRelay.asDriver(),
            laguageBinding: lanugageFirstBinding.asDriver()
        )
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
                    
                case .failure(let error):
                     Log.error("error Occur : \(error)")
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
    private func dissmissAction(action: Driver<Void>, problemID: Driver<ProblemID>) {
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
                return vm.submissionUseCase
                    .updateSubmissionAction(model: domainModel)
                    .do(onNext: { flag in
                        if flag { //FIXME: 변경 사항이 있을때 즉, 업데이트 가 이루어졌을때 전달
                            vm.homeViewModel?.sendSubmission.accept(domainModel)
                            vm.historyViewModel?.sendSubmission.accept(domainModel)
                        }
                    })
            }
            .subscribe(with: self, onNext: { vm, value in
                vm.stepper?.steps.accept(CodestackStep.problemComplete)
            },onError: { vm, _ in
                vm.stepper?.steps.accept(CodestackStep.problemComplete)
            })
            .disposed(by: disposeBag)
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
                    .fetchProblemSubmissionHistory(id: id, state: "temp")
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

    
    
    /// 문제제출 메소드
    /// - Parameter action: 문제 id를 관찰하고 있는 Driver
    func sendAction(action: Signal<ProblemID>) {
        action
            .skip(1)
            .asObservable()
            .withUnretained(self)
            .flatMap { vm, _ in vm.determinProblem() }
            .withLatestFrom(sendProblemModel.asObservable()) { $1 }
            .withUnretained(self)
            .do(onNext: { vm, _ in vm.submitWaiting.accept(true) })
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .do(onError: { [weak self] _ in self?.submitWaiting.accept(false) })
            .flatMap { vm, model in vm.submissionUseCase.submitSubmissionAction(model: model.toTempDomain())}
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vm, submission in
                switch submission {
                case .success(let submission):
                    vm.viewInteractorAction(submission)
                case .failure(let err):
                    vm.viewErrorInteractorAction(err)
                    vm.submitWaiting.accept(false)
                     Log.debug("errorr: \(err)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func loadSourceCodeBy(language: LanguageVO) -> String {
        var name = language.name
        if language.name == "Node" || language.name == "Node.js" {
            name = "nodejs"
        } else {
            name = language.name
        }
        
        guard let path = Bundle.main.path(forResource: "\(name.lowercased())", ofType: "txt"),
              let strings = try? String(contentsOfFile: path)
        else { return "" }
        
        return strings
    }
    
    private func determinProblem() -> Observable<ProblemState> {
        self.problemRefreshResult
            .take(1)
            .asObservable()
            .filter { state in
                /// Fetch 에 성공인지, 실패인지 판별
                if case .fail = state {
                    self.stepper?.steps.accept(CodestackStep.toastMessage("문제의 정보를 가져오는데 실패하였습니다"))
                    return false
                }
                return true
            }
    }
    
    private func viewInteractorAction(_ submission: SubmissionVO) {
        
        // MARK: ViewInteractor Action flow
        // 1. submit Wating: indicator false 로변경
        // 2. solvedResult 제출 결과 반영
        // 3. SubmissionListResult에 리스트 반영
        // 4. tempSaveFlag 임시 저장 불가능 하게 변경
        // 5. Home, History ViewModel 에 전달 -> Domain Output Global 로 설정 ?
        submitWaiting.accept(false)
        solvedResult.accept(submission)
        
        _ = Observable.just(submission)
            .withLatestFrom(submissionListResult) { new , original -> [SubmissionVO] in
                return [new] + original
            }
            .bind(to: submissionListResult)
        
        tempSaveFlag.accept(false)
        
        //TODO: 제출 결과 -> HomeViewModel Binding - 전달완료
        //TODO: 제출 결과 -> HistoryViewModel Binding - 진행중
        self.homeViewModel?.sendSubmission.accept(submission)
        self.historyViewModel?.sendSubmission.accept(submission)
        
    }
    
    private func viewErrorInteractorAction(_ error: Error) {
        // FIXME: TOKEN SERVICE ERROR 변경해야됌
        if let error = submissionUseCase.mappError(error) {
            if let tokenErr = error as? TokenError {
                if tokenErr == TokenError.unowned {
                    self.stepper?.steps.accept(CodestackStep.toastMessage("서버에 response가 오지 않습니다"))
                }
                if tokenErr == TokenError.unauthorized {
                    self.stepper?.steps.accept(CodestackStep.loginNeeded)
                }
            } else if let _ = error as? SendError {
                self.stepper?.steps.accept(CodestackStep.toastMessage("같은 내용입니다"))
            }
        }
    }
}
