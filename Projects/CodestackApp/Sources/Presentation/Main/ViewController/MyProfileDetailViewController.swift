//
//  MyProfileDetailViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/12.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxFlow
import SwiftUI
import CommonUI

class MainViewController: UIViewController {
     
    static func create(dependency: ContributionViewModel) -> MainViewController {
        let vc = MainViewController()
//        vc.contiributionViewModel = dependency
        return vc
    }
    
    let backButton: BackButton = {
        let button = BackButton()
        return button
    }()
    
    private var _viewWillDisappear = PublishRelay<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .sky_blue
    
//        customBackKey()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _viewWillDisappear.accept(())
    }
    
    private func customBackKey() {
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
}
