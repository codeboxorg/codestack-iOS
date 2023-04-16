//
//  ContainerViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit

final class ContainerViewController: UIViewController {
    private var sideMenuViewController: SideMenuViewController!
    private var navigator: UINavigationController!
    private var rootViewController: UIViewControllerSideMenuDelegate! {
        didSet {
            rootViewController.delegate = self
            if let vc = rootViewController as? UIViewController{
                navigator.setViewControllers([vc], animated: false)
            }
        }
    }
    
    convenience init(sideMenuViewController: SideMenuViewController, rootViewController: ViewController) {
        self.init()
        self.sideMenuViewController = sideMenuViewController
        self.rootViewController = rootViewController
        self.navigator = UINavigationController(rootViewController: rootViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        addChildViewControllers()
        configureDelegates()
        configureGestures()
    }
    
    private func configureDelegates() {
        sideMenuViewController.delegate = self
        rootViewController.delegate = self
    }
    
    private func configureGestures() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeftGesture.direction = .left
        swipeLeftGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(swipeLeftGesture)
        
        let rightSwipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(swipedRight))
        rightSwipeGesture.cancelsTouchesInView = false
        rightSwipeGesture.edges = .left
        view.addGestureRecognizer(rightSwipeGesture)
    
//        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
//        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func swipedLeft() {
        sideMenuViewController.hide()
//        print("left")
    }
    
    @objc private func swipedRight(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
//        print("gestureRecognizer.edges : \(gestureRecognizer.edges)")
//        print("gestureRecognizer.state : \(gestureRecognizer.state)")
//        let translaction = gestureRecognizer.translation(in: self.view)
//        print("translaction : \(translaction)")
        sideMenuViewController.show()
//        print("rigth")
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
       
//
//        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
//
//            let translation = gestureRecognizer.translation(in: self.view)
//            // note: 'view' is optional and need to be unwrapped
//            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
//            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
//        }
    }
    
    func updateRootViewController(_ viewController: UIViewControllerSideMenuDelegate) {
        rootViewController = viewController
    }
    
    private func addChildViewControllers() {
        addChild(navigator)
        view.addSubview(navigator.view)
        navigator.didMove(toParent: self)
        
        addChild(sideMenuViewController)
        view.addSubview(sideMenuViewController.view)
        sideMenuViewController.didMove(toParent: self)
    }
}

extension ContainerViewController: SideMenuDelegate {
    func menuButtonTapped() {
        sideMenuViewController.show()
    }
    
    func itemSelected(item: ViewControllerPresentation) {
        switch item {
        case let .embed(viewController):
            updateRootViewController(viewController)
            sideMenuViewController.hide()
        case let .push(viewController):
            sideMenuViewController.hide()
            navigator.pushViewController(viewController, animated: true)
        case let .modal(viewController):
            sideMenuViewController.hide()
            navigator.present(viewController, animated: true, completion: nil)
        }
    }
}
