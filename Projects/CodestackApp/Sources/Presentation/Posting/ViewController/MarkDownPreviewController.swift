//
//  MarkDownPreviewController.swift
//  CodestackApp
//
//  Created by 박형환 on 4/19/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import SwiftUI
import UIKit
import CommonUI
import RxSwift

final class MarkDownPreviewController: BaseContentViewController<UIScrollView> {
    
    private var layoutConstraintHeight: NSLayoutConstraint?
    private(set) var containerView = UIView()
    private var disposeBag = DisposeBag()
    lazy var dismissButton: UIButton = UIView().makeSFSymbolButton(symbolName: "xmark")
    private(set) lazy var sendButton: LoadingUIButton = {
        let feedBack = BaseFeedBack(LoadingUIButton(frame: .zero, title: "발행하기"))
        return feedBack.button
    }()
    
    static func create(_ markdown: String) -> MarkDownPreviewController {
        let vc = MarkDownPreviewController(contentView: UIScrollView(frame: .zero))
        vc.markdown = markdown
        return vc
    }
    
    private var markdown: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func binding() {
        dismissButton.rx.tap
            .subscribe(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    override func addAutoLayout() {
        self.view.addSubview(dismissButton)
        self.view.addSubview(contentView)
        contentView.addSubview(containerView)
        
        dismissButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(60)
            make.leading.equalToSuperview().inset(12)
            make.width.height.equalTo(30)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(dismissButton.snp.bottom).offset(0)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.view.snp.bottom).offset(80)
            make.height.equalTo(400).priority(.low)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(5)
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(Position.screenWidth)
            make.height.equalTo(500).priority(.low)
            make.bottom.equalToSuperview()
        }
        
        let view = RichTextSwiftUIView(markdown, { [weak self] size in
            self?.layoutConstraintHeight?.constant = size
        })
        
        add(richTextView: view)
    }
    
    override func applyAttributes() {
        view.backgroundColor = .tertiarySystemBackground
        contentView.showsHorizontalScrollIndicator = false
        contentView.isScrollEnabled = true
        contentView.contentInset = .init(top: 0, left: 0, bottom: 150, right: 0)
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
