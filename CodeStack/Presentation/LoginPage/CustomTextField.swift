//
//  LoginView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/24.
//

import UIKit

class CustomTextField: UITextField{
    
    enum FieldType{
        case ID
        case PassWord
        case none
    }
    
    private var fieldType: FieldType = .none
    
    weak var placeAnimationDelegate: TextFieldAnimationDelegate?
    
    override func becomeFirstResponder() -> Bool {
        if let text = text,
           text.isEmpty{
            placeAnimationDelegate?.placeUpAnimation(self,fieldType)
        }
        return super.becomeFirstResponder()
    }
    override func resignFirstResponder() -> Bool {
        if let text = text,
           text.isEmpty{
            placeAnimationDelegate?.placeDownAnimation(self,fieldType)
        }
        return super.resignFirstResponder()
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect,
                     delegate: TextFieldAnimationDelegate,
                     type: FieldType){
        self.init(frame: frame)
        self.placeAnimationDelegate = delegate
        self.fieldType = type
        
        if fieldType == .PassWord {
            self.isSecureTextEntry = true
        }
        layoutConfigure()
        
    }
    
   
    
    private func layoutConfigure(){
        self.tintColor = UIColor.black
        addDoneButtonOnKeyboard()
    }
    
    fileprivate func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: .zero)
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let up: UIBarButtonItem = UIBarButtonItem(title: "up", style: .plain, target: self, action: #selector(self.doneButtonAction))
        
        let items = [up,flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc fileprivate func doneButtonAction() {
        self.endEditing(true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
        
    }
}
