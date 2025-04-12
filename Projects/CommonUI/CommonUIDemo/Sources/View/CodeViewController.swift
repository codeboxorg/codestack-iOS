//
//  CodeViewController.swift
//  CommonUIDemo
//
//  Created by hwan on 3/25/25.
//  Copyright © 2025 com.hwan. All rights reserved.
//

import UIKit
import CommonUI
import Then
import Highlightr
import SafariServices
import Global

final class CodeViewController: BaseViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait // 또는 .portraitUpsideDown 포함 가능
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    lazy var ediotrContainer = EditorContainerView().then { container in
        container.setDelegate(self)
    }
    
    lazy var editorController = EditorController(textView: ediotrContainer.codeUITextView)
    
    override func viewDidLoad() {
        layoutConfigure()
        ediotrContainer.codeUITextView.languageBinding(name: "C++")
        ediotrContainer.codeUITextView.layoutManager.delegate = editorController
        ediotrContainer.codeUITextView.delegate = editorController
        
    }
}



//MARK: - 코드 문제 설명 뷰의 애니메이션 구현부
extension CodeViewController {
    func showProblemDiscription() {
        //        problemPopUpView.snp.remakeConstraints { make in
        //            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        //            make.leading.trailing.equalToSuperview()
        //            make.height.equalTo(400)
        //        }
        ediotrContainer.numbersView.layer.setNeedsDisplay()
        //        ediotrContainer.codeUITextView.contentSize.height += problemPopUpView.bounds.height
    }
    
    //이거 먼저 선언
    func dismissProblemDiscription(button height: CGFloat = 44){
        //        problemPopUpView.snp.remakeConstraints { make in
        //            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        //            make.leading.trailing.equalToSuperview()
        //            make.height.equalTo(height).priority(.high)
        //        }
        ediotrContainer.numbersView.layer.setNeedsDisplay()
    }
}

//MARK: - layout setting
extension CodeViewController {
    private func layoutConfigure() {
        //        self.view.addSubview(problemPopUpView)
        self.view.addSubview(ediotrContainer)
        
        let initialHeight = 44
        
        //        problemPopUpView.snp.makeConstraints { make in
        //            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        //            make.leading.trailing.equalToSuperview()
        //            make.height.equalTo(initialHeight)
        //        }
        
        ediotrContainer.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(self.view.snp.height).priority(.low)
        }
        
        ediotrContainer.codeUITextView.snp.remakeConstraints { make in
            //            make.top.equalTo(problemPopUpView.snp.bottom)
            make.top.equalToSuperview()
            make.trailing.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
    }
}




extension CodeViewController: TextViewSizeTracker {
    func updateNumberViewsHeight(_ height: CGFloat){
        ediotrContainer.numbersView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
}
extension CodeViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.navigationController?.popViewController(animated: true)
    }
}

