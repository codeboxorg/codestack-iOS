//
//  ContainerViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import RxCocoa
import RxSwift

final class ContainerViewController: UIViewController {
    private var sideMenuViewController: SideMenuViewController!
//    private var navigator: UINavigationController!
//    private var rootViewController: UIViewControllerSideMenuDelegate! {
//        didSet {
//            rootViewController.delegate = self
//            if let vc = rootViewController as? UIViewController{
//                navigator.setViewControllers([vc], animated: false)
//            }
//        }
//    }
    
    convenience init(sideMenuViewController: SideMenuViewController){ // }, rootViewController: ViewController) {
        self.init()
        self.sideMenuViewController = sideMenuViewController
//        self.rootViewController = rootViewController
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
//        sideMenuViewController.show()
    }
    
    private func configureView() {
        addChildViewControllers()
        configureDelegates()
        configureGestures()
        
    }
    
    private func configureDelegates() {
//        sideMenuViewController.delegate = self
//        rootViewController.delegate = self
    }
    
    private func configureGestures() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeftGesture.direction = .left
        swipeLeftGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(swipeLeftGesture)
        
//        let rightSwipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(swipedRight))
//        rightSwipeGesture.cancelsTouchesInView = false
//        rightSwipeGesture.edges = .left
//        view.addGestureRecognizer(rightSwipeGesture)
    }
    
    @objc private func swipedLeft() {
        sideMenuViewController.hide()
    }
    
//    @objc private func swipedRight(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
//        sideMenuViewController.show()
//    }
//
    
//    func updateRootViewController(_ viewController: UIViewControllerSideMenuDelegate) {
//        rootViewController = viewController
//    }
    
    private func addChildViewControllers() {
//        addChild(navigator)
//        view.addSubview(navigator.view)
//        navigator.didMove(toParent: self)
        
//        addChild(sideMenuViewController)
//        view.addSubview(sideMenuViewController.view)
//        sideMenuViewController.didMove(toParent: self)
    }
}

//extension ContainerViewController: SideMenuDelegate {
//    func menuButtonTapped() {
//        sideMenuViewController.show()
//    }
//
//    func moveToVC(_ name: String) {
//        guard let item = sideMenuViewController.sideMenuItems.filter({ item in
//            item.name == name
//        }).first else { return }
//
//        itemSelected(item: item.viewController)
//    }
    
//    func itemSelected(item: ViewControllerPresentation) {
//        switch item {
//        case let .embed(viewController):
//            updateRootViewController(viewController)
//            sideMenuViewController.hide()
//        case let .push(viewController):
//            sideMenuViewController.hide()
//            navigator.pushViewController(viewController, animated: true)
//        case let .modal(viewController):
//            sideMenuViewController.hide()
//            navigator.present(viewController, animated: true, completion: nil)
//        }
//    }
//}
