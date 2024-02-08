//
//  BaseViewController.swift
//  CodestackApp
//
//  Created by 박형환 on 1/20/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit

open class BaseVMViewController<Depepdency>: UIViewController {
    
    public init(dependency: Depepdency) {
        self.viewModel = dependency
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var viewModel: Depepdency
    
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
