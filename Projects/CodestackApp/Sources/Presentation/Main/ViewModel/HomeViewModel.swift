//
//  HomeViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/08.
//


import Global
import Domain
import RxFlow
import RxSwift
import RxCocoa


protocol HomeViewModelType: ViewModelType, Stepper, AnyObject {
    var sendSubmission: PublishRelay<SubmissionVO> { get set }
    var deleteSubmission: PublishRelay<SubmissionVO> { get set }
}

typealias SourceCode = String

final class HomeViewModel: HomeViewModelType {
    
    struct Input {
        var viewDidLoad: Signal<Void>
        var problemButtonEvent: Signal<ButtonType>
        var rightSwipeGesture: Observable<Void>
        var leftSwipeGesture: Observable<Void>
        var leftNavigationButtonEvent: Signal<Void>
        var recentModelSelected: Signal<HomeSection.HomeItem>
        var emptyDataButton: Signal<Void>
        var alramTapped: Observable<Void>
    }
    
    struct Output {
        var recentSubmissionModel: Driver<[RecentSubmission]>
        var homeDataModel: Driver<[HomeSection.HomeSectionModel]>
    }
    
    var steps = PublishRelay<Step>()
    
    private var homeUsecase: HomeUsecase
    private let codestackUsecase: CodestackUsecase
    private var disposeBag: DisposeBag = DisposeBag()
    
    //MARK: - Input
    var sendSubmission = PublishRelay<SubmissionVO>()
    var updateSubmission = PublishRelay<SubmissionVO>()
    var deleteSubmission = PublishRelay<SubmissionVO>()
    
    private var recentSubmissionList = BehaviorRelay<[SubmissionVO]>(value: SubmissionVO.getMocksForHome())
    private var postingList = BehaviorRelay<[StoreVO]>(value: StoreVO.getMocksForHome())
    
    //MARK: - output
    private var recentSubmissionModel = PublishRelay<[RecentSubmission]>()
    private var emptySignal = PublishRelay<Bool>()
    private var homeDataModel = BehaviorRelay<[HomeSection.HomeSectionModel]>(value: [])
    
    // TODO: History ViewModel Assembly에서 생성할때 .container scope로 생성하기 때문에 shared swinject에 저장이 되어있음
    // logout 할때 해제가 안되어서 지속적으로 데이터를 들고 있음
    // 1. 데이터의 중복을 제거하거나
    // 2. 데이터를 초기화 시키거나
    // 3. 데이터를 
    struct Dependency {
        let homeUsecase: HomeUsecase
        let codestackUsecase: CodestackUsecase
    }
    
    init(dependency: Dependency){
        self.homeUsecase = dependency.homeUsecase
        self.codestackUsecase = dependency.codestackUsecase
        sendSubmissionBinding()
        updateSubmissionBinding()
        deletedSubmissionBinding()
    }
    
    private func sendSubmissionBinding() {
        sendSubmission
            .map { $0 }
            .subscribe(with: self,onNext: { vm, submission in
                vm.updateSubmission.accept(submission)
            }).disposed(by: disposeBag)
    }
    
    private func deletedSubmissionBinding() {
        deleteSubmission
            .map { $0 }
            .withLatestFrom(recentSubmissionList) { [weak self] (willDeleteSub, subs) -> [SubmissionVO] in
                guard let self else { return [] }
                return self.deleteSubmissionList(will: willDeleteSub, original: subs)
            }
            .bind(to: recentSubmissionList)
            .disposed(by: disposeBag)
    }
    
    private func updateSubmissionBinding() {
        updateSubmission
            .map { $0 }
            .withLatestFrom(recentSubmissionList) { [weak self] (updatedSubmission, subs) -> [SubmissionVO] in
                guard let self else { return [] }
                return self.updateSubmissionList(will: updatedSubmission, original: subs)
            }
            .bind(to: recentSubmissionList)
            .disposed(by: disposeBag)
    }
    
    func transform(input: Input) -> Output {
        Observable.combineLatest(recentSubmissionList, postingList)
            .map { data in 
                [data.0.toHomeSubmissionSectionModel(),
                 data.1.toHomePostingSectionModel()]
            }
            .bind(to: homeDataModel)
            .disposed(by: disposeBag)
        
        buttonAction(input)
        gestureAction(input)
        viewDidLoadAction(input.viewDidLoad)
        codestackAction()
        recentModelAction(input.recentModelSelected)
        
        #if DEBUG
        // homeUsecase.removeForTest()
        #endif
        
        return Output(
            recentSubmissionModel: recentSubmissionModel.asDriver(onErrorJustReturn: []),
            homeDataModel: homeDataModel.asDriver(onErrorJustReturn: [])
        )
    }
    
    private func gestureAction(_ input: Input) {
        input.rightSwipeGesture
            .withUnretained(self)
            .subscribe(onNext: {vm,  _ in
                vm.steps.accept(CodestackStep.sideShow)
            }).disposed(by: disposeBag)
        
        input.leftSwipeGesture
            .withUnretained(self)
            .subscribe(onNext: {vm, value in
                vm.steps.accept(CodestackStep.sideDissmiss)
            }).disposed(by: disposeBag)
    }
    
    
    private func buttonAction(_ input: Input) {
        input.problemButtonEvent
            .withUnretained(self)
            .emit{ vm,type in
                switch type{
                case .today_problem(let step):
                    vm.steps.accept(step ?? .fakeStep)
                case .recommand_problem(_):
                    // TODO: Rich Text Kit
                    vm.steps.accept(CodestackStep.fakeStep)
                default:
                    vm.steps.accept(CodestackStep.fakeStep)
                }
            }.disposed(by: disposeBag)
        
        input.alramTapped
            .subscribe(with: self,onNext: { vm , value in
                vm.steps.accept(CodestackStep.historyflow)
            }).disposed(by: disposeBag)
        
        input.emptyDataButton
            .emit(with: self, onNext: { vm, _ in
                vm.steps.accept(CodestackStep.problemList)
            }).disposed(by: disposeBag)
        
        input.leftNavigationButtonEvent
            .map { CodestackStep.sideShow }
            .emit(to: steps)
            .disposed(by: disposeBag)
    }
    
    func viewDidLoadAction(_ viewDidLoad: Signal<Void>) {
        let loadSubmission 
        =
        viewDidLoad
            .withUnretained(self)
            .flatMap { vm, _ in
                vm.homeUsecase
                    .fetchSubmissionList()
                    .asSignal(onErrorJustReturn: [])
            }
            .map { $0 + [SubmissionVO.sample] }
        
        loadSubmission
            .skip(1)
            .emit(to: recentSubmissionList)
            .disposed(by: disposeBag)
            
        loadSubmission
            .asObservable()
            .take(1)
            .skeletonDelay()
            .bind(to: recentSubmissionList)
            .disposed(by: disposeBag)
    }

    private func recentModelAction(_ recentModelSelected: Signal<HomeSection.HomeItem>) {
        recentModelSelected
            .compactMap { value -> StoreVO? in
                if case let .writingList(store) = value { return store }
                else { return nil }
            }
            .withUnretained(self)
            .flatMapLatest { vm, value in
                vm.codestackUsecase
                    .fetchPostByID(value.markdownID)
                    .asSignal(onErrorJustReturn: .init(markdown: ""))
            }
            .map { CodestackStep.richText($0.markdown) }
            .emit(to: steps)
            .disposed(by: disposeBag)
        
        recentModelSelected
            .compactMap {
                if case let .recent(subVO) = $0 { return subVO }
                else { return nil }
            }
            .withUnretained(self)
            .flatMapLatest { vm, submission in
                vm.homeUsecase.fetchProblem(using: submission)
                    .asSignal(onErrorRecover: { error in
                        return .just(SubmissionVO.sample)
                    })
            }
            .compactMap { submission in submission.problemVO.toProblemList(submission) }
            .map { CodestackStep.recentSolveList($0)}
            .emit(to: steps)
            .disposed(by: disposeBag)
    }
    
    private func codestackAction() {
        let fetchStoreOB = codestackUsecase
            .fetchPostInfoList()
            .map(\.store)
            .map { $0.sortByDate() }
            .share()
        
        fetchStoreOB.take(1)
            .skeletonDelay()   // TODO: Test
            .bind(to: postingList)
            .disposed(by: disposeBag)
        
        fetchStoreOB
            .skip(1)
            .withLatestFrom(postingList) { storeVO, original in storeVO + original }
            .map { $0.filter(\.isNotMock) }
            .bind(to: postingList)
            .disposed(by: disposeBag)
    }
    
    private func deleteSubmissionList(will deleteSubmission: SubmissionVO,
                                      original submissions: [SubmissionVO]) -> [SubmissionVO] {
        let id = deleteSubmission.problem.id
        
        let originalIDs = submissions.map(\.problem.id)
        
        let flag = originalIDs.contains(id)
        
        if flag {
            let newSubmissions: [SubmissionVO] = submissions.filter {
                $0.problem.id != deleteSubmission.problem.id
            }
            let sortedSubmissions: [SubmissionVO] = newSubmissions.sortByDate()
            return Array(sortedSubmissions.prefix(11))
        } else {
            let array = submissions
            return Array(array.prefix(11))
        }
    }
    
    private func updateSubmissionList(will updateSubmission: SubmissionVO,
                                      original submissions: [SubmissionVO]) -> [SubmissionVO] {
        let id = updateSubmission.problem.id
        
        let originalIDs = submissions.map(\.problem.id)
        
        let flag = originalIDs.contains(id)
        
        if flag {
            let newSubmissions: [SubmissionVO] = submissions.map {
                $0.problem.id == updateSubmission.problem.id ? updateSubmission : $0
            }
            let sortedSubmissions: [SubmissionVO] = newSubmissions.sortByDate()
            return Array(sortedSubmissions.prefix(11))
        } else {
            let array = [updateSubmission] + submissions
            return Array(array.prefix(11))
        }
    }
}
