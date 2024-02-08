//
//  BaseRegisterVC.swift
//  CodestackApp
//
//  Created by 박형환 on 1/20/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import CommonUI

internal class BaseRegisterVC: BaseVMViewController<RegisterViewModel> {
    
    override var prefersStatusBarHidden: Bool { return true }
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        return scrollView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    let statusViewMedium: ProgressView = {
        let view = ProgressView(progressViewStyle: .bar)
        view.tintColor = .label
        view.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
        view.setProgress(0, animated: false)
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "chevron.backward")!
            .resize(targetSize: CGSize(width: 24, height: 24))
            .withTintColor(.label)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(popVC(_:)), for: .touchUpInside)
        return button
    }()
    
    var step: RegisterEnum?
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @objc func popVC(_ sender: UIButton) {
        viewModel.popToRootViewController(value: self.step!)
    }
    
    var disposeBag = DisposeBag()
    
    override func addAutoLayout() {
        view.addSubview(backButton)
        view.addSubview(scrollView)
        view.addSubview(statusViewMedium)
        scrollView.addSubview(containerView)        
        
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(30)
        }
        
        statusViewMedium.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(12)//.offset(44)
            make.leading.trailing.equalToSuperview().inset(12)//.inset(24)
            make.height.equalTo(4)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(statusViewMedium.snp.bottom).offset(1)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.height.equalTo(view.snp.height).priority(.low)
        }
    }
    
    override func applyAttributes() {
        containerView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        statusViewMedium.setProgress(1 / 3, animated: false)
    }
    
    override func binding() {
        keyboardBinding()
    }
    
    //MARK: - Binding Logic
    private func keyboardBinding(){
        let keyboard = KeyBoardManager.shared.getKeyBoardLifeCycle()
        
        keyboard
            .keyBoardAppear
            .asInfallible()
            .subscribe(with: self, onNext: { vc, rect in
                vc.scrollView.isScrollEnabled = true
                vc.remakeScrollViewLayout(value: rect.height)
            }).disposed(by: disposeBag)
        
        keyboard
            .keyBoardDissapear
            .asInfallible()
            .subscribe(with: self,onNext: { vc, _ in
                vc.scrollView.isScrollEnabled = false
                vc.remakeScrollViewLayout(value: 0)
            }).disposed(by: disposeBag)
    }
    
    private func remakeScrollViewLayout(value: CGFloat){
        scrollView.snp.remakeConstraints { make in
            make.top.equalTo(statusViewMedium.snp.bottom).offset(1)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-value)
        }
    }
}
