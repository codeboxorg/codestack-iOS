//
//  TagSeletedViewController.swift
//  CodestackApp
//
//  Created by 박형환 on 3/5/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxFlow
import Domain
import CommonUI


final class TagSeletedViewController: BaseViewController {
    
    static func create(with viewmodel: WritePostingViewModel) -> TagSeletedViewController {
        let vc = TagSeletedViewController()
        vc.viewModel = viewmodel
        return vc
    }
    
    lazy var dismissButton: UIButton = self.view.makeSFSymbolButton(symbolName: "xmark")
    
    private var viewModel: WritePostingViewModel!
    
    override func addAutoLayout() {
        self.view.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(60)
            make.leading.equalToSuperview().inset(12)
            make.width.height.equalTo(30)
        }
    }
    
    override func applyAttributes() {
        self.view.backgroundColor = .systemBackground
    }
    
    override func binding() {
        
    }
}
