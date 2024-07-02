//
//  View-Binder.swift
//  CodestackApp
//
//  Created by 박형환 on 5/30/24.
//  Copyright © 2024 com.hwan. All rights reserved.
//

import RxSwift
import UIKit
import CommonUI
import Domain

final class BinderProvider: _BinderProvider<CodeEditorViewController> {

    lazy var languageBinder: Binder<String> = {
        Binder(viewController) { controller, languageName in
            controller
                .problemPopUpView
                .languageButton
                .setTitle(languageName, for: .normal)
        }
    }()
    
    lazy var favoriteBinder: Binder<Bool> = {
        Binder(viewController) { controller, flag in
            controller
                .problemPopUpView
                .heartButton
                .flag = flag
        }
    }()
    
    lazy var problemPopUpViewPageBinder: Binder<SolveResultType> = {
        Binder(viewController) { controller, solveResultType in
            switch solveResultType {
            case .problem:
                controller.problemPopUpView.remakeWkWebViewHeight()
            case let .result(submission):
                controller.problemPopUpView.remakeResultStatus(height: 300)
                controller.problemPopUpView.scrollView.contentOffset = CGPoint.zero
                if let submission {
                    controller.problemPopUpView.resultStatusView.status.onNext(submission)
                }
            case .resultList(_):
                controller.problemPopUpView.remakeSubmissionListResults(height: 300)
            }
        }
    }()
    
    lazy var submissionLoadingBinder: Binder<Bool> = {
        Binder(viewController) { controller, flag in
            let button = controller.problemPopUpView.sendButton
            flag ? button.showLoading() : button.hideLoading()
        }
    }()
    
    lazy var problemStateBinder: Binder<CodeEditorViewModel.ProblemState> = {
        Binder(viewController) { controller, state in
            let popUp = controller.problemPopUpView
            
            popUp.activityIndicator.stopAnimating()
            popUp.refreshButton.isHidden = false
            popUp.refreshLabel.text = "페이지 로드에 실패하였습니다."
            
            if case let .fetched(problem) = state {
                popUp.refreshLabel.removeFromSuperview()
                popUp.refreshButton.removeFromSuperview()
                popUp.loadHTMLToWebView(html: problem.context)
                return
            }
        }
    }()
    
    
    lazy var sourceCodeBinder: Binder<(LanguageVO, String)> = {
        Binder(viewController) { controller, value in
            let (language, sourceCode) = value
            let textView = controller.ediotrContainer.codeUITextView
            textView.languageBinding(language: language)
            if !controller.sourceCodeState {
                textView.text = ""
                textView.text = sourceCode
            } else {
                controller.sourceCodeState = false
            }
        }
    }()
}
