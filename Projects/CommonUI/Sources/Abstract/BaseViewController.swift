//
//  BaseViewController.swift
//  CommonUI
//
//  Created by 박형환 on 2/1/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit

open class BaseContentViewController<ContentView>: UIViewController {
    typealias ContentView = UIView
    
    public init(contentView: ContentView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var contentView: ContentView
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        addAutoLayout()
        applyAttributes()
        binding()
    }
    
    open func addAutoLayout() { }
    
    open func applyAttributes() { }
    
    open func binding() { }
}


open class BaseViewController: UIViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()
        addAutoLayout()
        applyAttributes()
        binding()
    }
    
    open func addAutoLayout() { }
    
    open func applyAttributes() { }
    
    open func binding() { }
}

