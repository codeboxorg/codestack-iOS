//
//  SideMenuDelegate.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import Foundation

protocol SideMenuDelegate: AnyObject {
    func menuButtonTapped()
    func itemSelected(item: ViewControllerPresentation)
}
