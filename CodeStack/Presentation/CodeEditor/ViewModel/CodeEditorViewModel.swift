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


protocol CodeEditorViewModelType: ViewModelType{
//    func perform(send model: SendProblemModel,_ completion: @escaping (Result<Submission,Error>) -> () )
    func perform(send model: SendProblemModel,_ completion: @escaping (Submission) -> () )
}

class CodeEditorViewModel: CodeEditorViewModelType,Stepper{
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    
    typealias SourceCode = String
    
    struct Input{
        var dismissAction: Driver<Void>
        var sendAction: Driver<ID>
        var language: Driver<Language>
        var sourceCode: Driver<SourceCode>
    }
    
    struct Output{
        var solvedResult: Driver<Submission>
    }
    
    struct Dependency{
        let service: ApolloServiceType
        let homeViewModel: any HomeViewModelType
        let historyViewModel: any HistoryViewModelType
    }
    
    init(service: ApolloServiceType){
        apolloService = service
    }
    
    init(dependency: Dependency){
        self.apolloService = dependency.service
        self.homeViewModel = dependency.homeViewModel
        self.historyViewModel = dependency.historyViewModel
    }
    
    private var homeViewModel: (any HomeViewModelType)?
    private var historyViewModel: (any HistoryViewModelType)?
    private var apolloService: ApolloServiceType?
    private var disposeBag = DisposeBag()
    
    private var languageRelay = BehaviorRelay<Language>(value: Language(id: "0",
                                                                        name: "C++",
                                                                        _extension: "cpp"))
    private var sourceCodeRelay = BehaviorRelay<SourceCode>(value: "")
    private var solvedResult = PublishRelay<Submission>()
    private var sendProblemModel = PublishSubject<SendProblemModel>()
    
    func transform(input: Input) -> Output {
        
        dissmissAction(action: input.dismissAction)
        languageAction(action: input.language)
        sourceCodeAction(action: input.sourceCode)
        sendAction(action: input.sendAction)
      
        return Output(solvedResult: solvedResult.asDriver(onErrorJustReturn: .init(_problem: .init(title: "fail"))))
    }
    
    
    //MARK: - Action Binding FUNC
    func dissmissAction(action: Driver<Void>){
        action
            .map{_ in CodestackStep.problemComplete}
            .asSignal(onErrorJustReturn: .problemComplete)
            .emit(with: self,onNext: { vm, steps in
                vm.steps.accept(steps)
            })
            .disposed(by: disposeBag)
    }
    
    func sourceCodeAction(action: Driver<SourceCode>){
        action
            .drive(with: self,onNext: { vm, sourceCode in
                vm.sourceCodeRelay.accept(sourceCode)
            }).disposed(by: disposeBag)
    }
    
    func languageAction(action: Driver<Language>){
        action
            .drive(with: self,onNext: { vm, language in
                vm.languageRelay.accept(language)
            }).disposed(by: disposeBag)
    }
    
    func sendAction(action: Driver<ID>){
        let combine = Driver.combineLatest(languageRelay.asDriver(), sourceCodeRelay.asDriver())
        action
            .withLatestFrom(combine.asDriver()){ id, value in
                let (language, code) = value
                return SendProblemModel(problemID: "\(id)", sourceCode: code, languageID: language.id)
            }
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .subscribe(with: self,onNext: { vm, sendProblemModel in
                
                vm.perform(send: sendProblemModel){ submission in
                    vm.solvedResult.accept(submission)
                    
                    // TODO: 제출 결과 -> HomeViewModel Binding - 전달완료
                    // TODO: 제출 결과 -> HistoryViewModel Binding - 진행중
                    if let home = vm.homeViewModel,
                       let history = vm.historyViewModel{
                        home.sendSubmission.accept(submission)
                        history.sendSubmission.accept(submission)
                    }
                    
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    //MARK: - Service code
    func perform(send model: SendProblemModel,_ completion: @escaping (Submission) -> () ){
        
        let mutation = Mutation.problemSubmit(problemId: model.problemID,
                                                   languageId: model.languageID,
                                                   sourceCode: model.sourceCode)
        Log.debug("perform send : \(model.problemID)")
        _ = apolloService?.perform(mutation: mutation,max: 2)
            .subscribe(with: self,
                       onSuccess: { vm, result in
                let submission = Submission(with: result.createSubmission)
                completion(submission)
            },onError: {vm, err in
                if let err = err as? TokenAcquisitionError,
                err == TokenAcquisitionError.unauthorized{
                    vm.steps.accept(CodestackStep.loginNeeded)
                }
            })
        
    }
}
