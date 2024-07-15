//
//  RIchTextView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/26.
//
import UIKit
import SnapKit
import RichTextKit
import RxSwift
import RxCocoa
import Global
import Domain
import RichText
import SwiftUI
import RxGesture
import CommonUI


final class RichTextViewController<Group: ActionButtonGroup>: BaseContentViewController<UIScrollView> {
    private(set) var containerView = UIView()
    private(set) var postingTitle = PostingTitleView()
    
    private(set) lazy var tagContainer: TagContainer = {
        let container = TagContainer(frame: self.view.frame, spacing: 10)
        return container
    }()
    
    var richTextSwiftUIView: some View {
        RichTextSwiftUIView(htmlString, { [weak self] height in
           self?.layoutConstraintHeight?.constant = height
       })
    }
    
    private var rightTopActionButton: Group?
    
    /// Layout
    /// SwiftUI View 가 로드될때 ScrollView의 높이를 계산하기 위한 Constraint
    private var layoutConstraintHeight: NSLayoutConstraint?
    
    struct Dependency {
        let html:     String
        let storeVO:  StoreVO
        let usecase:  FirebaseUsecase
        let viewType: ViewType
        let group:    Group
    }
    
    static func create(with dependency: Dependency) -> RichTextViewController
    {
        let vc = RichTextViewController(contentView: UIScrollView())
        vc.htmlString = dependency.html
        vc.viewmodel = RichViewModel(
            storeVO: dependency.storeVO,
            markDownString: dependency.html,
            usecase: dependency.usecase,
            viewType: dependency.viewType
        )
        vc.rightTopActionButton = dependency.group
        return vc
    }
    
    private(set) var htmlString: String = ""
    private(set) var writerInfo: WriterInfo?
    private var viewmodel: RichViewModel!
    
    private var disposebag = DisposeBag()
    
    override func applyAttributes() {
        view.backgroundColor = .tertiarySystemBackground
        contentView.showsHorizontalScrollIndicator = false
        contentView.isScrollEnabled = true
        contentView.contentInset = .init(top: 0, left: 0, bottom: 150, right: 0)
        
        self.navigationItem.rightBarButtonItem
        = self.rightTopActionButton?.makeRightBarButtonItem { [weak self] action in
            if let actionType = ActionType(rawValue: action.title) {
                if actionType == .setting { return }
                self?.viewmodel.sendActionWrapper = actionType
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.view.backgroundColor = .tertiarySystemBackground
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.backgroundColor = .systemBackground
    }
    
    override func addAutoLayout() {
        _addAutoLayout()
        add(richTextView: richTextSwiftUIView)
    }
    
    override func binding() {
        
        posingBinding()
        
        if self.viewmodel.viewType != .preview {
            hideTopBottomGestureBinding()
        } else {
            // preViews
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    
    private func hideTopBottomGestureBinding() {
        contentView.rx.panGesture()
            .skip(1)
            .asTranslation()
            .asDriver(onErrorJustReturn: (.zero,.zero))
            .throttle(.milliseconds(200))
            .map(\.translation.y)
            .drive(animationBinder)
            .disposed(by: disposebag)
    }
    
    private func posingBinding() {
        // TODO: Tap Gesture 처리
        _ = [
            postingTitle.writerLabel.rx.tapGesture().when(.recognized),
            postingTitle.profileImageView.rx.tapGesture().when(.recognized),
            postingTitle.dateLabel.rx.tapGesture().when(.recognized)
        ]
        
        postingTitle.writerBinder.onNext(.mock)
        
        viewmodel.transForm()
            .observe(on: MainScheduler.instance)
            .bind(to: postingTitle.writerBinder)
            .disposed(by: disposebag)
        
        viewmodel.$postingState
            .asDriver(onErrorJustReturn: .none)
            .drive(
                with: self,
                onNext: { vc, values in
                    vc.showAlertUI(state: values)
                }
            )
            .disposed(by: disposebag)
        
        tagContainer.setTagItem(viewmodel.storeVO.tags)
        let height = tagContainer.intrinsicContentSize.height
        
        tagContainer.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
    
    private func showAlertUI(state: PostingState) {
        switch state {
        case .failedToPublish:
            break
        case .published:
            break
        case .saving:
            break
        case .savingFail:
            break
        case .deleted:
            break
        case .deletedFail:
            break
        case .reported:
            break
        case .reportedFail:
            break
        case .none:
            break
        }
    }
    
    private func _addAutoLayout() {
        view.addSubview(contentView)
        contentView.addSubview(postingTitle)
        contentView.addSubview(tagContainer)
        contentView.addSubview(containerView)
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.snp.bottom).offset(80)
            make.height.equalTo(400).priority(.low)
        }
        
        postingTitle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(Position.screenWidth)
            make.height.equalTo(200).priority(.low)
        }
        
        tagContainer.snp.makeConstraints { make in
            make.top.equalTo(postingTitle.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(tagContainer.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(Position.screenWidth)
            make.height.equalTo(500).priority(.low)
            make.bottom.equalToSuperview()
        }
    }
}


extension PostingTitleView {
    var writerBinder: Binder<WriterInfo> {
        Binder<WriterInfo>(self) { view, writeInfo in
            view.apply(writeInfo)
            if writeInfo.isMock {
                view.layoutIfNeeded()
                view.titleLabel.addSkeletonView()
                view.writerLabel.addSkeletonView()
                view.dateLabel.addSkeletonView()
                view.profileImageView.addSkeletonView()
            } else {
                view.removeSkeletonViewFromSuperView()
            }
        }
    }
}

extension RichTextViewController {
    
    private var animationBinder: Binder<CGFloat> {
        Binder<CGFloat>(self){ vc, translationY in
            if translationY == 0 { return }
            guard let hidden = vc.navigationController?.isNavigationBarHidden else { return }
            if translationY > 0 {
                if hidden {
                    vc.navigationController?.setNavigationBarHidden(false, animated: true)
                    vc.tabBarController?.tabBar.showWithAnimation()
                    vc.contentView.snp.updateConstraints { make in
                        make.top.equalTo(vc.view.safeAreaLayoutGuide.snp.top).offset(0)
                    }
                }
            } else {
                if !hidden {
                    vc.navigationController?.setNavigationBarHidden(true, animated: true)
                    vc.tabBarController?.tabBar.hideWithAnimation()
                    vc.contentView.snp.updateConstraints { make in
                        make.top.equalTo(vc.view.safeAreaLayoutGuide.snp.top).offset(-10)
                    }
                }
            }
            UIView.animate(withDuration: 0.4, animations: { vc.view.layoutIfNeeded() })
        }
    }
    
    private func add(richTextView: some View) {
        let vc = UIHostingController(rootView: richTextView)
        let richText = vc.view!
        richText.translatesAutoresizingMaskIntoConstraints = false
        richText.backgroundColor = .tertiarySystemBackground
        
        addChild(vc)
        
        containerView.addSubview(richText)
        
        self.layoutConstraintHeight = richText.heightAnchor.constraint(equalToConstant: Position.screenHeihgt)
        
        NSLayoutConstraint.activate([
            richText.topAnchor.constraint(equalTo: containerView.topAnchor),
            richText.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            richText.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            layoutConstraintHeight!,
            richText.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        vc.didMove(toParent: self)
    }
}
