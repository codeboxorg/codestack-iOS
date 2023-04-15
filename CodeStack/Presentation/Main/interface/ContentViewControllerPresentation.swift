//
//  enum.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit

enum ViewControllerPresentation {
    case embed(ViewController)
    case push(UIViewController)
    case modal(UIViewController)
}
