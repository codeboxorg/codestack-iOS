//
//  KeyBoardLayoutManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/18.
//

import UIKit
import RxSwift
import RxCocoa

class KeyBoardManager{
    
    static let shared = KeyBoardManager()
    
    private init(){
        keyBoardConfiguration()
    }
    
    struct Output{
        let keyBoardAppear: Signal<CGRect>
        let keyBoardDissapear: Signal<Void>
        let keyBoardDissapeard: Signal<Void>
    }
    
    let keyBoardAppear = PublishSubject<CGRect>()
    let keyBoardDissapear = PublishSubject<Void>()
    let keyBoardDissapeard = PublishSubject<Void>()
    
    func getKeyBoardLifeCycle() -> Output{
        return Output(keyBoardAppear: keyBoardAppear.asSignal(onErrorJustReturn: CGRect()),
                      keyBoardDissapear: keyBoardDissapear.asSignal(onErrorJustReturn: ()),
                      keyBoardDissapeard: keyBoardDissapeard.asSignal(onErrorJustReturn: ()))
    }
    
    private func keyBoardConfiguration(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc private func keyboardDidHide(_ notification: Notification){
        keyBoardDissapeard.onNext(())
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyBoardAppear.onNext(keyboardFrame)
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        keyBoardDissapear.onNext(Void())
    }
}
