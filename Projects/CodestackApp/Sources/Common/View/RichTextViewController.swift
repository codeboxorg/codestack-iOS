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


final class RichTextViewController: BaseContentViewController<UIScrollView> {

    private(set) var containerView = UIView()
    private(set) var postingTitle = PostingTitleView()
    
    private var richTextSwiftUIView: some View {
        RichTextSwiftUIView(htmlString, { [weak self] height in
           self?.layoutConstraintHeight?.constant = height
       })
    }
    
    struct Dependency {
        let html: String
        let storeVO: StoreVO
        let usecase: FirebaseUsecase
        let viewType: RichViewModel.ViewType
    }
    
    static func create(with dependency: Dependency) -> RichTextViewController {
        let vc = RichTextViewController(contentView: UIScrollView())
        vc.htmlString = dependency.html
        vc.viewmodel = RichViewModel(storeVO: dependency.storeVO,
                                     usecase: dependency.usecase,
                                     viewType: dependency.viewType)
        return vc
    }
    
    private var layoutConstraintHeight: NSLayoutConstraint?
    private(set) var htmlString: String = ""
    private(set) var writerInfo: WriterInfo?
    private var viewmodel: RichViewModel!
    
    private var disposebag = DisposeBag()
    
    override func applyAttributes() {
        view.backgroundColor = .tertiarySystemBackground
        contentView.showsHorizontalScrollIndicator = false
        contentView.isScrollEnabled = true
        contentView.contentInset = .init(top: 0, left: 0, bottom: 150, right: 0)
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

        contentView.rx.panGesture()
            .skip(1)
            .asTranslation()
            .asDriver(onErrorJustReturn: (.zero,.zero))
            .throttle(.milliseconds(200))
            .map(\.translation.y)
            .drive(animationBinder)
            .disposed(by: disposebag)
    }
    
    private func _addAutoLayout() {
        view.addSubview(contentView)
        contentView.addSubview(postingTitle)
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
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(postingTitle.snp.bottom).offset(5)
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

final class RichViewModel {
    
    enum ViewType {
        case preview
        case posting
        case myPosting
    }
    
    var storeVO: StoreVO
    var viewType: ViewType = .posting
    private let observable = PublishSubject<WriterInfo>()
    private let usecase: FirebaseUsecase
    
    init(storeVO: StoreVO, usecase: FirebaseUsecase, viewType: ViewType) {
        self.storeVO = storeVO
        self.usecase = usecase
        self.viewType = viewType
    }
    
    func transForm() -> Observable<WriterInfo> {
        if viewType == .posting || viewType == .myPosting {
            return transFormPosting()
        } else {
            return transformPreview()
        }
    }
    
    private func transFormPosting() -> Observable<WriterInfo> {
        DispatchQueue.global().asyncAfter(deadline: .now(), execute: {
            Task {
                [weak self] in
                    guard let self else { return }
                    let storeVO = self.storeVO
                    let cached = ImageCacheClient.shared.getOtherImageFromCache(.init(key: .other(storeVO.userId)))
                    
                    var info = WriterInfo(title: storeVO.title,
                                          writer: storeVO.name,
                                          date: storeVO.date,
                                          image: UIImage(named: "codeStack")!)
                    
                    if let cached {
                        info.image = cached
                        self.observable.onNext(info)
                        return
                    }
                    
                    let stream = self.usecase.fetchOtherUserImagePath(uid: storeVO.userId).values
                    
                    for try await imagePath in stream {
                        let cacheKey = CacheKey(key: .other(storeVO.name))
                        let image = await ImageCacheClient.shared.getOtherImageFromCache(cacheKey, imagePath)
                        info.image = image ?? UIImage(named: "codeStack")!
                    }
                    observable.onNext(info)
            }
        })
        
        return observable.asObservable()
    }
    
    private func transformPreview() -> Observable<WriterInfo> {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self else { return }
            let storeVO = self.storeVO
            let cached = ImageCacheClient.shared.getMyImageFromCache()
            
            var info = WriterInfo(title: storeVO.title,
                                  writer: storeVO.name,
                                  date: storeVO.date,
                                  image: UIImage(named: "codeStack")!)
            if let cached {
                info.image = cached
            }
            self.observable.onNext(info)
        }
        return observable.asObservable()
    }
}
