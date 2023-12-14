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
import Data
import Global
import Domain

enum FavoriteError: Error {
    case error
}

protocol CodeEditorViewModelType: ViewModelType { }

final class CodeEditorViewModel: CodeEditorViewModelType {
    
    typealias SourceCode = String
    
    struct Input {
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
    private weak var homeViewModel: (any HomeViewModelType)?
    private weak var historyViewModel: (any HistoryViewModelType)?
    private var submissionUseCase: SubmissionUseCase
    
    private var disposeBag = DisposeBag()
    
    private var languageRelay = BehaviorRelay<LanguageVO>(value: LanguageVO.default)
    private var sourceCodeRelay = BehaviorRelay<SourceCode>(value: "")
    
    private var sourceCodeCache: [String: SourceCode] = [:]
    
    private var sendProblemModel = BehaviorRelay<SendProblemModel>(value: .default)

    // MARK: Output
    private var solvedResult = PublishRelay<SubmissionVO>()
    private var submitWaiting = BehaviorRelay<Bool>(value: false)
    
    private var submissionListResult = BehaviorRelay<[SubmissionVO]>(value: [])
    private var submissionListWaiting = BehaviorRelay<Bool>(value: false)
    
    private var favoriteProblem = BehaviorRelay<Bool>(value: false)
    
    
    enum ProblemState {
        case fetched(ProblemVO)
        case fail(Error)
    }
    
    private var problemRefreshResult = PublishRelay<ProblemState>()
    
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
            problemRefreshResult: problemRefreshResult.asSignal(), 
            favoritProblem: favoriteProblem.asDriver(),
            loadSourceCode: sourceCodeRelay.asDriver()
        )
    }
    
    private func favoriteProblemAction(action: Driver<Bool>) {
        action
            .asObservable()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] value -> Observable<(SendProblemModel, Bool)> in
                guard let self else { return .empty() }
                return Observable.zip(self.sendProblemModel.take(1).asObservable(),
                                      Observable.just(value))
            }
            .flatMapLatest { [weak self] model, flag -> Observable<State<Bool>> in
                guard let useCase = self?.submissionUseCase else { return .empty() }
                let favoriteProblem = model.makeFavoirtProblem()
                return useCase.updateFavoritProblem(model: favoriteProblem, flag: flag)
            }
            .subscribe(with: self, onNext: { vm, result in
                switch result {
                case .success(let flag):
                    vm.favoriteProblem.accept(flag)
                case .failure(let error):
                    Log.debug(error)
                    vm.favoriteProblem.accept(false)
                }
            }).disposed(by: disposeBag)
    }
    
    private func problemRefreshAction(action: Driver<Void>) {
        action
            .asObservable()
            .flatMap { [weak self] _ -> Observable<SendProblemModel> in
                guard let self else { return .empty() }
                return self.sendProblemModel.take(1).asObservable()
            }
            .delay(.milliseconds(800), scheduler: MainScheduler.instance)
            .flatMap { [weak self] model -> Observable<State<ProblemVO>> in
                guard let useCase = self?.submissionUseCase else { return .empty() }
                return useCase.fetchProblem(id: model.problemID)
            }
            .subscribe(with: self, onNext: { vm, result in
                switch result {
                case .success(let problem):
                    vm.problemRefreshResult.accept(.fetched(problem))
                case .failure(let error):
                    vm.problemRefreshResult.accept(.fail(error))
                }
            }).disposed(by: disposeBag)
    }
    
    //MARK: - Action Binding FUNC
    private func dissmissAction(action: Driver<Void>, problemID: Driver<ID>) {
        action
            .asObservable()
            .withLatestFrom(sendProblemModel.asObservable()) { $1 }
            .withUnretained(self)
            .flatMap { vm, sendModel in
                vm.submissionUseCase
                    .updateSubmissionAction(model: sendModel.toTempDomain())
                    .do(onNext: { updateFlag in
                        if let home = vm.homeViewModel,
                           let _ = vm.historyViewModel,
                            updateFlag {
                            let submission = sendModel.toTempDomain()
                            home.sendSubmission.accept(submission)
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
        action
            .flatMap {[weak self] sourceCode -> Driver<(LanguageVO, SourceCode)>  in
                guard let self else { return .empty() }
                return Observable
                    .zip(self.languageRelay.take(1), Observable.just(sourceCode))
                    .asDriver(onErrorJustReturn: (LanguageVO.default, ""))
            }
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
    
    private func loadSubmissionList(action: Driver<Void>, probelmID: Driver<ID>) {
        action
            .asObservable()
            .take(1)
            .flatMap { _ in probelmID.asObservable().take(1) }
            .flatMap { [weak self] (id) -> Observable<Result<[SubmissionVO], Error>> in
                guard let self else { return .just(.success([])) }
                return self.submissionUseCase.fetchProblemSubmissionHistory(id: id, state: "temp")
            }
            .map { result in
                if case let .success(submissions) = result {
                    return submissions.sorted(by: { s1,s2 in
                        if let createdAt1 = s1.createdAt.toDateKST(),
                           let createdAt2 = s2.createdAt.toDateKST() {
                            return createdAt1 > createdAt2
                        }
                        return false
                    })
                }
                return []
            }
            .subscribe(with: self, onNext: { vm, submissions in
                vm.submissionListResult.accept(submissions)
            }).disposed(by: disposeBag)
    }

    
    
    /// 문제제출 메소드
    /// - Parameter action: 문제 id를 관찰하고 있는 Driver
    func sendAction(action: Signal<ID>) {
        action
            .skip(1)
            .withLatestFrom(sendProblemModel.asSignal(onErrorJustReturn: .default)) { $1 }
            .asObservable()
            .withUnretained(self)
            .do(onNext: { vm, _ in vm.submitWaiting.accept(true) })
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .do(onError: { [weak self] _ in self?.submitWaiting.accept(false) })
            .flatMap { vm, model in vm.submissionUseCase.submitSubmissionAction(model: model.toTempDomain())}
            .observe(on: MainScheduler.instance)
            .subscribe(with: self,onNext: { vm, submission in
                switch submission {
                case .success(let submission):
                    vm.viewInteractorAction(submission)
                case .failure(let err):
                    vm.viewErrorInteractorAction(err)
                    vm.submitWaiting.accept(false)
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
        
        Log.debug(Bundle.main)
        Log.debug(Bundle.module)
        guard let path = Bundle.main.path(forResource: "\(name.lowercased())", ofType: "txt"),
              let strings = try? String(contentsOfFile: path)
        else { return "" }
        
        return strings
    }
    
    private func viewInteractorAction(_ submission: SubmissionVO) {
        self.submitWaiting.accept(false)
        self.solvedResult.accept(submission)
        //TODO: 제출 결과 -> HomeViewModel Binding - 전달완료
        //TODO: 제출 결과 -> HistoryViewModel Binding - 진행중
        if let home = self.homeViewModel,
           let history = self.historyViewModel{
            home.sendSubmission.accept(submission)
            history.sendSubmission.accept(submission)
        }
    }
    
    private func viewErrorInteractorAction(_ error: Error) {
        if let err = error as? TokenAcquisitionError {
            if err == TokenAcquisitionError.unowned {
                self.stepper?.steps.accept(CodestackStep.toastMessage("서버에 response가 오지 않습니다"))
            }
            
            if err == TokenAcquisitionError.unauthorized {
                self.stepper?.steps.accept(CodestackStep.loginNeeded)
                return
            }
        }
        
        if let _ = error as? SendError {
            self.stepper?.steps.accept(CodestackStep.toastMessage("같은 내용입니다"))
            return
        }
    }
}
