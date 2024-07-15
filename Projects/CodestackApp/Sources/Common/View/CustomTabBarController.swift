//
//  CustomTabBarController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/13.
//

import UIKit
import SwiftUI
import RxFlow
import CommonUI
import RxSwift
import RxCocoa

protocol TabBarDelegate: AnyObject{
    func setSelectedItem(for vc: TabBarItem)
}

enum TabBarItem: Int {
    case home = 0
    case problem = 1
    case codeStack = 2
    case history = 3
    case mypage = 4
}

final class CustomTabBarController: UITabBarController, TabBarDelegate, UITabBarControllerDelegate {
    
    public var stepper: RxFlow.Stepper?
    private(set) var disposeBag = DisposeBag()
    
    private lazy var presentView
    = ShowMiddleActionView(
        frame: .zero
    )
    
    var presentViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setValue(CustomTabBar(), forKey: "tabBar")
        self.tabBar.layer.zPosition = 100
        
        self.view.addSubview(presentView)
        
        presentViewBottomAnchor
        =
        presentView
            .bottomAnchor
            .constraint(
                equalTo: self.view.bottomAnchor,
                constant: (Position.screenHeihgt / 5)
            )
        
        NSLayoutConstraint.activate([
            presentView.widthAnchor.constraint(equalToConstant: Position.screenWidth),
            presentView.heightAnchor.constraint(equalToConstant: Position.screenHeihgt / 5),
            presentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            presentViewBottomAnchor!
        ])
        
        presentView.alpha = 0
        
        presentView.writeCodeButton.rx.tap
            .map { _ in CodestackStep.codeEditorStep(CodeEditor(codestackVO: .new, select: .default)) }
            .subscribe(
                with: self,
                onNext: { vc, value in
                    vc.stepper?.steps.accept(value)
                }
            )
            .disposed(by: disposeBag)
        
        presentView.writePostingButton.rx.tap
            .map { _ in CodestackStep.postingWrtieStep }
            .subscribe(
                with: self,
                onNext: { vc, value in
                    vc.stepper?.steps.accept(value)
                }
            )
            .disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
#if Dev
        print("TabBarController - View DidLayout Subviews")
#endif
        let frame = tabBar.frame
        
        let origin = CGPoint(
            x: frame.origin.x - 5,
            y: frame.origin.y + 12
        )
        
        let size = CGSize(
            width: frame.size.width + 10,
            height: frame.size.height
        )
        
        tabBar.frame = CGRect(
            origin: origin,
            size: size
        )
    }
    
    func addTabBarItems() {
        for (item, vc) in zip(UIImage.tabBarItems, viewControllers ?? []) {
            vc.tabBarItem = item
        }
        setUpMiddleButton()
    }
    
    func setSelectedItem(for vc: TabBarItem){
        self.selectedIndex = vc.rawValue
    }
    
    private lazy var action: (UIAction) -> Void = { [weak self] action in
        self?.presentViewAction()
    }
    
    private func setUpMiddleButton() {
        if let tabBar = self.tabBar as? CustomTabBar {
            tabBar.setupMiddleButton(
                self.view.bounds,
                action
            )
            self.view.layoutIfNeeded()
        }
    }
    
    private func presentViewAction() {
        if let tabBar = self.tabBar as? CustomTabBar {
            tabBar.rotateFlag ? dissmiss() : present()
        }
    }
    
    private func present() {
        presentViewBottomAnchor?.constant = 0
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.presentView.isHidden = false
                self?.presentView.alpha = 1
                self?.view.layoutIfNeeded()
            }
        )
    }
    
    private func dissmiss() {
        presentViewBottomAnchor?.constant = (Position.screenHeihgt / 5)
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.presentView.alpha = 0
                self?.view.layoutIfNeeded()
            }
        )
    }
}

private class ShowMiddleActionView: BaseView {
    
    public var writeCodeButton = UIButton()
    public var writePostingButton = UIButton()
    
    override func applyAttributes() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = dynamicSysBackground
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        
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
        self.addSubview(writeCodeButton)
        self.addSubview(writePostingButton)
        
        writeCodeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.width.equalTo(Position.screenWidth / 2 - 42)
            make.height.equalTo(50)
            make.leading.equalToSuperview().inset(16)
        }
        
        writePostingButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.width.equalTo(Position.screenWidth / 2 - 42)
            make.height.equalTo(50)
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    // TODO: 트러블 슈팅 작성 HitTest
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        for member in subviews.reversed() {
            let subPoint = member.convert(point, from: self)
            guard let result = member.hitTest(subPoint, with: event) else {
                continue
            }
            return result
        }
        return nil
    }
}
