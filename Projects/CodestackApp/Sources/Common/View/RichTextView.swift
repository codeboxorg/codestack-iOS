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

final class RichTextViewController: BaseViewController<UIScrollView> {
    
    private(set) var containerView = UIView()
    private(set) var postingTitle = PostingTitleView()
    
    static func create(with html: String) -> RichTextViewController {
        let vc = RichTextViewController(contentView: UIScrollView())
        vc.htmlString = html
        return vc
    }
    
    private lazy var richTextLayoutHeight: CGFloat = 500 {
        didSet {
            self.layoutConstraintHeight?.constant = richTextLayoutHeight
        }
    }
    
    private var layoutConstraintHeight: NSLayoutConstraint?
    private(set) var htmlString: String = ""
    private var disposebag = DisposeBag()
    
    override func applyAttributes() {
        view.backgroundColor = .tertiarySystemBackground
        contentView.showsHorizontalScrollIndicator = false
        contentView.isScrollEnabled = true
        contentView.contentInset = .init(top: 0, left: 0, bottom: 300, right: 0)
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
        makeRichTextView(htmlString)
        postingTitle.apply(WriterInfo.mock)
    }
    
    private lazy var binder = Binder<CGFloat>(self) { vc, translationY in
        if translationY == 0 { return }
        guard let hidden = vc.navigationController?.isNavigationBarHidden else { return }
        if translationY > 0 {
            if hidden {
                vc.navigationController?.setNavigationBarHidden(false, animated: true)
                vc.tabBarController?.tabBar.showWithAnimation()
            }
        } else {
            if !hidden {
                vc.navigationController?.setNavigationBarHidden(true, animated: true)
                vc.tabBarController?.tabBar.hideWithAnimation()
            }
        }
    }
    
    override func binding() {
        contentView.rx.panGesture()
            .skip(1)
            .asTranslation()
            .asDriver(onErrorJustReturn: (.zero,.zero))
            .throttle(.milliseconds(200))
            .map(\.translation.y)
            .drive(binder)
            .disposed(by: disposebag)
    }
    
    private func _addAutoLayout() {
        view.addSubview(contentView)
        contentView.addSubview(postingTitle)
        contentView.addSubview(containerView)
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(44)
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
            make.top.equalTo(postingTitle.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(Position.screenWidth)
            make.height.equalTo(500).priority(.low)
            make.bottom.equalToSuperview()
        }
    }
}

//MARK: RichTextViewController Rich Text MarK Down - SwiftUI Extension
extension RichTextViewController {
    private func makeRichTextView(_ html: String) {
        let swRichText =
        RichText(html: html)
            .colorScheme(.auto)
            .fontType(.system)
            .linkOpenType(.SFSafariView())
            .customCSS(Style.codeBlockCss)
            .placeholder {
                SkeletonUIKit()
                    .frame(width: Position.screenWidth,
                           height: Position.screenHeihgt)
            }
            .onReadSize { [weak self] size in
                self?.richTextLayoutHeight = size.height
            }
        
        let vc = UIHostingController(rootView: swRichText)
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
            richText.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        vc.didMove(toParent: self)
    }
}
