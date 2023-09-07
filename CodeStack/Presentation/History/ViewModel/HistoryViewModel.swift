//
//  HistoryViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/18.
//


import UIKit
import RxSwift
import RxCocoa
import RxRelay


protocol HistoryViewModelType: ViewModelType{
    
    var sendSubmission: PublishRelay<Submission> { get set }
}

class HistoryViewModel: HistoryViewModelType{
    
    struct Input{
        var viewDidLoad: Signal<Void>
        var currentSegment: Driver<SegType.Value>
        var refreshTap: Signal<Void>
        var fetchHistoryList: Signal<Void>
        var paginationLoadingInput: Signal<Bool>
    }
    
    struct Output{
        var historyData: Driver<[Submission]>
        var refreshEndEvnet: Signal<Void>
        var paginationLoading: Driver<Bool>
    }
    
    private let service: ApolloServiceType
    
    init(service: ApolloServiceType){
        self.service = service
    }
    
    private var disposeBag = DisposeBag()
    private let dummyData = BehaviorRelay<[Submission]>(value: [])
    private let historyData = BehaviorRelay<[Submission]>(value: [])
    private let paginationLoading = BehaviorRelay<Bool>(value: false)
    
    
    private var currentPage: CurrentPage = 0
    private var totalPage: Int = 20
    
    private let refreshEndEvent = PublishRelay<Void>()
    var sendSubmission = PublishRelay<Submission>()
    
    
#if DEBUG
    private let testService: TestService = NetworkService()
#endif
    
    func transform(input: Input) -> Output {
        
        
        input.paginationLoadingInput
            .emit(to: paginationLoading)
            .disposed(by: disposeBag)
        
        observingSubmission()
        
        //TODO: - Refresh Button을 어떻게 구성할지
        refreshBinding(tap: input.refreshTap)
        viewDidLoadBinding(viewDidLoad: input.viewDidLoad)
        fetchHistoryBinding(fetchHistory: input.fetchHistoryList)
        
        dummyData.withLatestFrom(historyData){  submission, original in
            original + submission
        }
        .subscribe(with: self,onNext: { vm, submission in
            vm.historyData.accept(submission)
        }).disposed(by: disposeBag)
        
        
        let filteredHistoryData =
        Driver<[Submission]>.combineLatest(historyData.asDriver(),
                                           input.currentSegment)
        {   submissions, segment in
            let filteredSubmissions = submissions.filter{ $0.statusCode?.checkIsEqual(with: segment) ?? false}
            return filteredSubmissions
        }
        
        return Output(historyData: filteredHistoryData,
                      refreshEndEvnet: refreshEndEvent.asSignal(),
                      paginationLoading: paginationLoading.asDriver(onErrorJustReturn: false))
    }
    
    func observingSubmission(){
        sendSubmission
            .withLatestFrom(dummyData){ value, original in
                return [value] + original 
            }.subscribe(with: self, onNext: { vm, value in
                vm.dummyData.accept(value)
            }).disposed(by: disposeBag)
    }
    
    func viewDidLoadBinding(viewDidLoad: Signal<Void>){
        viewDidLoad
            .emit(with: self,onNext: { vm, _ in
                vm.requestSubmission()
            })
            .disposed(by: disposeBag)
        //        viewDidLoad
        //            .compactMap{[weak self] _ in
        //                guard let self else { return []}
        //                return self.testService.request(type: .all).content
        //            }.emit(to: dummyData)
        //            .disposed(by: disposeBag)
    }
    
    func fetchHistoryBinding(fetchHistory list: Signal<Void>) {
        list
            .withUnretained(self)
            .filter{ vm, _ in
                if vm.currentPage >= vm.totalPage{
                    vm.paginationLoading.accept(false)
                    vm.refreshEndEvent.accept(())
                    return false
                }
                return true
            }.delay(.milliseconds(300))
            .emit(with: self,onNext: { vm, _ in
                vm.currentPage += 1
                Log.debug("vm.currentPage: \(vm.currentPage)")
                vm.requestSubmission(offset: vm.currentPage)
            }).disposed(by: disposeBag)
    }
    
    func refreshBinding(tap: Signal<Void>){
        tap.emit(with: self,onNext: { vm, _ in
            vm.requestMe()
            vm.requestSubmission()
        }).disposed(by: disposeBag)
    }
    
    private func requestMe(){
        //TODO: - 현재 SolvedProblem만 가지고 온다.
        // 에러나 성공 실패 했을때의 결과에 대한 Submission을 가지고 오기 위해서는
        // Submission에 조건을 달아서 query를 날려야 하나?
        service.getMe(query: Query.getMe())
            .subscribe(with: self, onSuccess: { vm , me in
                Log.debug(me)
            })
    }
    
    
    //TODO: - "INTERNAL_SERVER_ERROR",
    // 현재 getMe 의 submission query Internal Server Error 발생
    private func requestGetMeSubmissions(){
        _ = service.getMeSubmissions(query: Query.getMeSubmissions())
            .subscribe(with: self,onSuccess: { vm, submissions in
                
            },onError: { vm , error in
                Log.error(error)
            })
    }
    
    private func requestSubmission(offset: Int = 0){
        _ = service.getSubmission(query: Query.getSubmission(offest: offset))
            .subscribe(with: self,onSuccess: { vm, data in
                vm.dummyData.accept(data)
                vm.refreshEndEvent.accept(())
                vm.paginationLoading.accept(false)
            },onError: { vm , error in
                vm.refreshEndEvent.accept(())
                vm.paginationLoading.accept(false)
            })
    }
}

//MARK: - Debug code

//submissions.forEach{ sub in
//    Log.debug("sub.id :\(sub.id)")
//    Log.debug("sub.sourceCode :\(sub.sourceCode)")
//    Log.debug("sub.createdAt :\(sub.createdAt)")
//    Log.debug("sub.language :\(sub.language)")
//    Log.debug("sub.problem.id :\(sub.problem.id)")
//    Log.debug("sub.problem.title :\(sub.problem.title)")
//}

//                data.content?.forEach({ content in
//                    _  = """
//                                START💡💡💡💡💡💡💡💡💡💡💡💡💡💡💡💡💡💡💡💡
//                                    content.id :\(content.id)
//                                    content.sourceCode :\(content.sourceCode)
//                                    content.updatedAt :\(content.updatedAt)
//                                    content.createdAt :\(content.createdAt)
//                                    content.language :\(content.language)
//                                    content.problem.id :\(content.problem.id)
//                                    content.problem.title :\(content.problem.title)
//                                End❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️
//                                """
//                })
