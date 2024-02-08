//
//  TestViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import Global
import Then
import Domain


class HistoryViewController: UIViewController {
    
    weak var historyViewModel: (any HistoryViewModelType)?
    
    static func create(with dependency: any HistoryViewModelType) -> HistoryViewController {
        let history = HistoryViewController()
        history.historyViewModel = dependency as? HistoryViewModel
        return history
    }
    
    private let container: ContainerView = {
        let view = ContainerView(frame: .zero)
        view.backgroundColor = .tertiarySystemBackground
        return view
    }()
    
    private let historySegmentList: HistorySegmentedControl = {
        let seg = HistorySegmentedControl(frame: .zero)
        return seg
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.tintColor = UIColor.sky_blue
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        return button
    }()
    
    private let historyList: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        table.alwaysBounceVertical = false
        return table
    }()
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        return label.headLineLabel(size: 18, text: "💡현재 기록된 활동이 없습니다", color: .dynamicLabelColor)
    }()
    
    private let editButton = UIButton().then { button in
        button.setTitle("수정하기", for: .normal)
        button.setTitleColor(.sky_blue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    private var disposeBag = DisposeBag()
    
    private var fetchHistoryList = PublishRelay<Void>()
    private var paginationLoadingInput = BehaviorRelay<Bool>(value: false)

    private var deleteHistory = PublishRelay<Int>()
    private var editModeValue = BehaviorRelay<Bool>(value: false)
    
    /// 로그아웃시 Swinject Custom Scope History 초기화를 위한 Relay
    private var deinitPublisher = PublishRelay<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutConfigure()
        binding()
        view.gestureRecognizers?.forEach{ $0.delegate = self }
    }
    
    deinit { deinitPublisher.accept(()) }

    private func binding(){
        let currentSegment = gestureBinding()
        
        let output
        =
        (historyViewModel as! HistoryViewModel)
            .transform (
                input: HistoryViewModel.Input(
                    viewDidLoad: OB.justVoid(),
                    currentSegment: currentSegment,
                    refreshTap: refreshButton.rx.tap.asSignal(),
                    fetchHistoryList: fetchHistoryList.asSignal(),
                    paginationLoadingInput: paginationLoadingInput.asSignal(onErrorJustReturn: false),
                    deleteHistory: deleteHistory.asSignal(),
                    logout: deinitPublisher.asSignal()
                )
            )
            
        historyList.setEditing(false, animated: false)
        historyList.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        historyDeleteBinding(deleteAction: historyList.rx.itemDeleted.asObservable())
        editButtonBinding(editButton: editButton.rx.tap.asSignal(), count: output.historyData.map(\.count))
        
        scrollBinding(scroll: historyList.rx.didScroll.asDriver(), currentSegment: currentSegment, paginationLoading: output.paginationLoading)
        
        outputBinding(output: output, paginationLoading: output.paginationLoading)
    }
    
    private func outputBinding(output: HistoryViewModel.Output, paginationLoading: Driver<Bool>) {
        Observable
            .combineLatest(output.historyIsEmpty.asObservable(), paginationLoading.asObservable())
            .asDriver(onErrorJustReturn: (false, false))
            .drive(with: self, onNext: { vc, tuple in
                let (dataEmpty, loading) = tuple
                if !dataEmpty {
                    vc.emptyLabel.removeFromSuperview()
                    return
                }
                loading ? vc.emptyLabel.removeFromSuperview(): vc.addEmptylabel()
            }).disposed(by: disposeBag)
        
        output.historyData
            .drive(historyList.rx.items(cellIdentifier: HistoryCell.identifier,
                                        cellType: HistoryCell.self))
        { index , submission , cell in
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets.zero
            cell.onHistoryData.accept(submission)
            cell.onStatus.accept(submission.statusCode.convertSolveStatus() )
        }.disposed(by: disposeBag)
        
        output.paginationRefreshEndEvent
            .emit(with: self,onNext: { vc, _ in
                vc.historyList.removeBottomRefresh()
            }).disposed(by: disposeBag)
        
        output.refreshClearEvent
            .emit(with: self,onNext: { vc, value in
                Toast.toastMessage("...새로고침 완료...",
                                   offset: UIScreen.main.bounds.height - 250,
                                   background: .sky_blue,
                                   boader: UIColor.black.cgColor)
            }).disposed(by: disposeBag)
    }
    
    private func gestureBinding() -> Driver<SegType.Value> {
        let rightGesture = historyList.rx.gesture(.swipe(direction: .right))
            .withUnretained(self)
            .filter { vc, _ in !vc.historyList.isEditing }
            .compactMap{ vc, _ in
                if vc.historySegmentList.selectedSegmentIndex != 0{
                    vc.historySegmentList.selectedSegmentIndex -= 1
                    return vc.historySegmentList.selectedSegmentIndex
                }
                return nil
            }.asDriver(onErrorJustReturn: 0)
        
        
        let leftGesture = historyList.rx.gesture(.swipe(direction: .left))
            .withUnretained(self)
            .filter { vc, _ in !vc.historyList.isEditing }
            .compactMap{ vc, _ in
                if vc.historySegmentList.selectedSegmentIndex != 4{
                    vc.historySegmentList.selectedSegmentIndex += 1
                    return vc.historySegmentList.selectedSegmentIndex
                }
                return nil
            }.asDriver(onErrorJustReturn: 0)
        
        let historyDriver = historySegmentList.rx.selectedSegmentIndex.asDriver()
        
        let historySegmentUtil = Driver.merge([rightGesture,leftGesture,historyDriver]).asDriver()
        
        historySegmentUtil
            .drive(with: self,
                   onNext: { vm, _ in
                vm.historySegmentList.layer.setNeedsDisplay()
            }).disposed(by: disposeBag)
        
        
        let currentSegment
        =
        historySegmentUtil.map { [weak self] value in
            let segTypeValue = SegType.Value(rawValue: value) ?? SegType.Value.all
            if case .all = segTypeValue { self?.editButton.isHidden = true }
            else { self?.editButton.isHidden = false }
            return segTypeValue
        }.asDriver()
        
        return currentSegment
    }
    
    private func historyDeleteBinding(deleteAction: Observable<IndexPath>) {
        self.historyList.rx.itemDeleted
            .map { $0.row }
            .subscribe(with: self, onNext: { vc, indexPaths in
                // TODO:  Index Paths Delete Logic
                vc.deleteHistory.accept(indexPaths)
            }).disposed(by: disposeBag)
    }
    
    private func editButtonBinding(editButton: Signal<Void>, count: Driver<Int>) {
        editButton
            .asObservable()
            .withUnretained(self)
            .flatMapFirst { vm, _ in  count.asObservable().take(1) }
            .filter { $0 != 0 }
            .subscribe(with: self, onNext: { vc, count in
                let isEditing = !vc.historyList.isEditing
                vc.editModeValue.accept(isEditing)
                vc.historyList.setEditing(isEditing, animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func scrollBinding(scroll: Driver<Void>,
                       currentSegment: Driver<SegType.Value>,
                       paginationLoading: Driver<Bool> ) {
        Driver.combineLatest(scroll, currentSegment)
            .throttle(.milliseconds(500))
            .filter { $1.isAll() }
            .flatMapLatest{ _ in
                paginationLoading
                    .asObservable()
                    .take(1)
                    .asDriver(onErrorJustReturn: false)
            }
            .filter { !$0 }
            .drive(with: self,onNext: { vc , _ in
                let table = vc.historyList
                if table.contentOffset.y > table.contentSize.height - table.bounds.height {
                    table.addBottomRefresh(width: vc.view.frame.width)
                    vc.paginationLoadingInput.accept(true)
                    vc.fetchHistoryList.accept(())
                }
            }).disposed(by: disposeBag)
    }
}

//MARK: - Layout configure
extension HistoryViewController {
    
    func addEmptylabel() {
        self.historyList.addSubview(self.emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
    }
    
    func layoutConfigure(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshButton)
        self.view.backgroundColor = .tertiarySystemBackground
        
        view.addSubview(container)
        view.addSubview(historyList)
        view.addSubview(editButton)
        container.addSubview(historySegmentList)
        
        
        historySegmentList.selectedSegmentIndex = SegType.Value.all.rawValue
        
        historyList.snp.makeConstraints{
            $0.top.equalTo(container.snp.bottom).offset(12)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        let editButtonWidth = "수정하기".width(withConstrainedHeight: 40, font: editButton.titleLabel!.font) + 10
        editButton.snp.makeConstraints { make in
            make.centerY.equalTo(historySegmentList.snp.centerY)
            make.trailing.equalTo(historySegmentList.snp.trailing)
            make.width.equalTo(editButtonWidth)
        }
        
        container.snp.makeConstraints{
            $0.height.equalTo(44)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
        
        historySegmentList.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalToSuperview()
        }
    }
}

extension HistoryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
        return false
    }
}

extension HistoryViewController: UITableViewDelegate {
    
    private func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        Log.debug("tableView Swped : false")
        return true // Swipe 비활성화
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        } else {
            return .none
        }
    }
}
