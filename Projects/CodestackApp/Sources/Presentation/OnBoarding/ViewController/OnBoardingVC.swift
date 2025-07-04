//
//  OnBoardingVC.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/14.
//

import UIKit
import RxFlow
import RxCocoa
import Global

class OnBoardingVC: UIViewController,Stepper {
    
    var steps: RxRelay.PublishRelay<RxFlow.Step> = PublishRelay<Step>()
    
    var initialStep: Step {
        CodestackStep.none
    }
    
    private lazy var welcomLabel: UILabel = {
        let label = UILabel()
        label.text = "환영합니다"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    deinit {
        Log.debug("Deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        view.addSubview(welcomLabel)
        welcomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nav = self.navigationController?.navigationBar
        
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
        
        nav?.topItem?.leftBarButtonItem = makeSFSymbolButton(self, action: #selector(dismissVC(_:)), symbolName: "xmark")
        nav?.topItem?.title = "OnBoarding"
        
        NSLayoutConstraint.activate([
            welcomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc func dismissVC(_ sender: Any){
        steps.accept(CodestackStep.onBoardingComplte)
    }
    
}
