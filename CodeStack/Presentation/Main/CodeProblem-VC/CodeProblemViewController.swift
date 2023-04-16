//
//  CodeProblemViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit


class CodeProblemViewController: UIViewController{
    
    weak var delegate: SideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
    }
}
