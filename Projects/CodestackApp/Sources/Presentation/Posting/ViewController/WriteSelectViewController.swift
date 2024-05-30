//
//  PostingViewController.swift
//  CodestackApp
//
//  Created by 박형환 on 2/28/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import CommonUI
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxFlow

final class ContainerViewController: BaseViewController {
    override func applyAttributes() {
        self.view.backgroundColor = .clear
    }
}

final class WriteSelectViewController: BaseViewController, Stepper {
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    
    public var writeCodeButton = UIButton()
    public var writePostingButton = UIButton()
    var disposeBag = DisposeBag()
    
    override func applyAttributes() {
        self.view.backgroundColor = .systemBackground
        writeCodeButton.layer.cornerRadius = 12
        writeCodeButton.layer.borderWidth = 1
        writeCodeButton.layer.borderColor = dynamicLabelColor.cgColor
        writePostingButton.layer.cornerRadius = 12
        writePostingButton.layer.borderWidth = 1
        writePostingButton.layer.borderColor = dynamicLabelColor.cgColor
        writeCodeButton.setTitle("코드 작성하기", for: .normal)
        writePostingButton.setTitle("글 작성하기", for: .normal)
        writeCodeButton.setTitleColor(dynamicLabelColor, for: .normal)
        writePostingButton.setTitleColor(dynamicLabelColor, for: .normal)
    }
    
    override func addAutoLayout() {
        self.view.addSubview(writeCodeButton)
        self.view.addSubview(writePostingButton)
        
        writeCodeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.width.equalTo(Position.screenWidth / 2 - 32)
            make.height.equalTo(50)
            make.leading.equalToSuperview().inset(16)
        }
        
        writePostingButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.equalTo(writeCodeButton.snp.trailing).offset(16)
            make.width.equalTo(Position.screenWidth / 2 - 32)
            make.height.equalTo(50)
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    override func binding() {
        // TODO: User Langauge
        writeCodeButton.rx.tap
            .map { _ in CodestackStep.codeEditorStep(CodeEditor(codestackVO: .new, select: .default)) }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        writePostingButton.rx.tap
            .map { _ in CodestackStep.postingWrtieStep }
            .bind(to: steps)
            .disposed(by: disposeBag)
    }
}


