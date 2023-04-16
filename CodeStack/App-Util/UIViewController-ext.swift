//
//  UIViewController-ext.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit

protocol UIViewControllerSideMenuDelegate{
    var delegate: SideMenuDelegate? { get set }
}
extension ViewController: UIViewControllerSideMenuDelegate{}
extension CodeProblemViewController: UIViewControllerSideMenuDelegate{}
