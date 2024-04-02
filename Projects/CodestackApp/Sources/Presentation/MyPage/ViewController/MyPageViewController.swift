//
//  MyPageViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/05/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import Global
import SwiftUI
import Domain

typealias ProfileImage = UIImage

final class MyPageViewController: UIViewController {
    
    private(set) var myPageContainer = MyPageContainer(frame: .zero)
    
    struct Dependency {
        var myPageViewModel: MyPageViewModel
        var contiributionViewModel: ContributionViewModel?
    }
    
    static func create(with dependency: Dependency) -> MyPageViewController {
        let vc = MyPageViewController()
        vc.myPageViewModel = dependency.myPageViewModel
        vc.contiributionViewModel = dependency.contiributionViewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAutoLayout()
        calendarView()
        self.view.backgroundColor = UIColor.systemBackground
        binding()
    }
    
    var myPageViewModel: MyPageViewModel?
    private(set) var contiributionViewModel: ContributionViewModel?
    private var disposeBag = DisposeBag()
    
    private func binding() {
        let profileEditEvent = myPageContainer.profileView.editButton.rx.tap
            .withUnretained(myPageContainer.profileView)
            .flatMap { view, _ in
                let image = view.imageView.image ?? UIImage()
                let data = image.pngData() ?? Data()
                return Observable.just(data)
            }.asSignal(onErrorJustReturn: Data())
        
        let modelSelected 
        = myPageContainer
            .codestackListTableView.rx
            .modelSelected(CodestackVO.self)
            .asSignal()
        
        let myPostSeleted
        = myPageContainer
            .myPostingListTableView.rx
            .modelSelected(StoreVO.self)
            .asSignal()
        
        let itemDeleted = myPageContainer.codestackListTableView.rx.itemDeleted
            .map { $0.item }
        
        let navigateToCodeWrite = myPageContainer.emptyDataButton.rx.tap.asObservable()
        
        let output = myPageViewModel?
            .transform(input:
                    .init(editProfileEvent: profileEditEvent,
                          viewDidLoad: OB.justVoid(),
                          codeModelSeleted: modelSelected,
                          codeModelDeleted: itemDeleted,
                          myPostSeleted: myPostSeleted,
                          navigateToCodeWrite: navigateToCodeWrite)
            )
        
        output?.userProfile
            .drive(myPageContainer.profileView.profileBinder)
            .disposed(by: disposeBag)
        
        if let loading = output?.loading.asDriver() {
            myPageContainer.profileView.loadingBinding(loading)
        }
        
        viewBinding()
        codeTableViewBinding(output?.myCodestackList)
        myPostingTableViewBinding(output?.myPostingList)
    }
    
    func viewBinding() {
        let segSelected = myPageContainer.segmentList.rx.selectedSegmentIndex.asDriver()
        segSelected
            .drive(with: self, onNext: { vc, segIndex in
                vc.segSelected(segIndex)
                vc.myPageContainer.segmentList.selectedSegmentIndex = segIndex
                vc.myPageContainer.segmentList.layer.setNeedsDisplay()
            }).disposed(by: disposeBag)
        
        myPageContainer.editButton.rx.tap
            .asObservable()
            .subscribe(with: self, onNext: { vc, _ in
                let isEditing = !vc.myPageContainer.codestackListTableView.isEditing
                vc.myPageContainer.codestackListTableView.setEditing(isEditing, animated: true)
            })
            .disposed(by: disposeBag)
        
        myPageContainer.profileView.imageView.rx.gesture(.tap())
            .skip(1)
            .asDriver(onErrorJustReturn: .init())
            .drive(with: self, onNext: { vc, value in
                let imageVC = ProfileImageViewController.create(with: vc.myPageContainer.profileView.imageView.image)
                imageVC.modalPresentationStyle = .automatic
                vc.present(imageVC, animated: true)
            }).disposed(by: disposeBag)
    }
    
    func codeTableViewBinding(_ myCodestackList: Driver<[CodestackVO]>?) {
        myCodestackList?
            .drive(with: self, onNext: { vc, list in
                if list.isEmpty {
                    vc.myPageContainer.emptyLabel.isHidden = false
                    vc.myPageContainer.emptyDataButton.isHidden = false
                } else {
                    vc.myPageContainer.emptyLabel.isHidden = true
                    vc.myPageContainer.emptyDataButton.isHidden = true
                }
            }).disposed(by: disposeBag)
        
        myCodestackList?
            .drive(myPageContainer
                .codestackListTableView
                .rx.items(cellIdentifier: CodestackListCell.identifier,
                          cellType: CodestackListCell.self))
        { index , codestackVO , cell in
            cell.binder.onNext(codestackVO)
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets.zero
        }.disposed(by: disposeBag)
    }
    
    func myPostingTableViewBinding(_ myPostingList: Driver<[StoreVO]>?) {
        myPostingList?
            .drive(myPageContainer
                .myPostingListTableView
                .rx.items(cellIdentifier: MyPostingListCell.identifier,
                          cellType: MyPostingListCell.self))
        { index , storeVO , cell in
             cell.binder.onNext(storeVO)
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets.zero
        }.disposed(by: disposeBag)
    }
}

extension MyPostingListCell {
    var binder: Binder<StoreVO> {
        Binder<StoreVO>(self) { cell,value  in
            cell.titleTagView.setText(text: "\(value.title)")
            cell.applyTitleTagSize()
            cell.descriptionLabel.text = value.description
            cell.dateLabel.text = value.date
            cell.tags = nil
            cell.tags = value.tags
            
            if value.isMock {
                cell.layoutIfNeeded()
                cell.addSkeletonView()
            } else {
                cell.contentView.removeSkeletonViewFromSuperView()
            }
        }
    }
    
    private func addSkeletonView() {
        titleTagView.addSkeletonView()
        descriptionLabel.addSkeletonView()
        dateLabel.addSkeletonView()
        colorline.addSkeletonView()
        tagContainer.subviews.forEach {
            $0.addSkeletonView()
        }
    }
}


extension MyPageViewController {
    func segSelected(_ segIndex: Int) {
        switch segIndex {
        case 0:
            myPageContainer.graphContainerView.isHidden = false
            myPageContainer.codestackListTableView.isHidden = true
            myPageContainer.myPostingListTableView.isHidden = true
        case 1:
            myPageContainer.graphContainerView.isHidden = true
            myPageContainer.codestackListTableView.isHidden = false
            myPageContainer.myPostingListTableView.isHidden = true
        default:
            myPageContainer.graphContainerView.isHidden = true
            myPageContainer.codestackListTableView.isHidden = true
            myPageContainer.myPostingListTableView.isHidden = false
        }
    }
}

private extension MyPageViewController {
    func addAutoLayout() {
        self.view.addSubview(myPageContainer)
        myPageContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension MyPageViewController {
    //MARK: - 컨티리뷰션 그래프 뷰
    func calendarView() {
        guard let viewModel = self.contiributionViewModel else { return }
        
        let vc = UIHostingController(rootView: SubmissionChartView(viewModel: viewModel))
        
        let submissionChartView = vc.view!
        submissionChartView.translatesAutoresizingMaskIntoConstraints = false
        submissionChartView.backgroundColor = .systemBackground
        submissionChartView.layer.cornerRadius = 12
        
        addChild(vc)
        let container = myPageContainer.graphContainerView
        container.addSubview(submissionChartView)
        
        NSLayoutConstraint.activate([
            submissionChartView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            submissionChartView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            submissionChartView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            submissionChartView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        // 4
        // Notify the child view controller that the move is complete.
        vc.didMove(toParent: self)
    }
}
