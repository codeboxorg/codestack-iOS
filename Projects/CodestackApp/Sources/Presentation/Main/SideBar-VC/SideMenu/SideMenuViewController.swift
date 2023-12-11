//
//  SideMenuViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import RxFlow
import RxCocoa

struct SideMenuItem {
    let icon: UIImage?
    let name: String
    let presentation: CodestackStep
    
    static let items = [SideMenuItem(icon: UIImage(named: "problem"),
                                     name: "문제",
                                     presentation: .problemList),
                        SideMenuItem(icon: UIImage(named: "submit"),
                                     name: "제출근황",
                                     presentation: .recentSolveList(nil)),
                        SideMenuItem(icon: UIImage(named: "my"),
                                     name: "마이 페이지",
                                     presentation: .profilePage),
                        SideMenuItem(icon: UIImage(named: "home"),
                                     name: "메인 페이지",
                                     presentation: .none),
                        SideMenuItem(icon: UIImage(systemName: "hand.thumbsup"),
                                     name: "추천",
                                     presentation: .recommendPage),
                        SideMenuItem(icon: UIImage(systemName: "lock.open"),
                                     name: "로그아웃", presentation: .logout)]
    
}

//TODO: - SideTabBar Color 정하기
final class SideMenuViewController: UIViewController ,Stepper{
    
    static func create(with items: [SideMenuItem] = []) -> SideMenuViewController{
        return SideMenuViewController(sideMenuItems: SideMenuItem.items)
    }
    
    private var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .whiteGray
        return view
    }()
    
    private lazy var logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "codeStack"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var headerTitle: UILabel = {
        var label = UILabel()
        label = label.headLineLabel(size: 35, text: "CodeStack", color: .black)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private var sideMenuView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var sideMenuItems: [SideMenuItem] = []
    
    //sideMenuView.leadingAnchor.constraint
    private var sideMenuViewLeadingContraint: NSLayoutConstraint!
    
    private var shadowColor: UIColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 0.5)
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    
    
    deinit{
        Log.debug("sideMenu Deinit")
    }
    
    convenience init(sideMenuItems: [SideMenuItem]) {
        self.init()
        self.sideMenuItems = sideMenuItems
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        self.view.backgroundColor = .clear
        headerView.layer.cornerRadius = 12
        headerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        tableView.layer.cornerRadius = 12
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
    }
    
    func show() {
        self.view.frame.origin.x = 0
        self.view.backgroundColor = self.shadowColor
        UIView.animate(withDuration: 0.3) {
            self.sideMenuViewLeadingContraint.constant = 0
            if let parent = self.parent{
                parent.navigationController?.navigationBar.isHidden = true
                parent.navigationController?.navigationItem.titleView?.tintColor = .black
            }
            self.view.layoutIfNeeded()
        }
    }

    func hide() {
        self.view.backgroundColor = .clear
        UIView.animate(withDuration: 0.3) {
            self.sideMenuViewLeadingContraint.constant = -UIApplication.getScreenSize()
            if let parent = self.parent{
                parent.navigationController?.navigationBar.isHidden = false
                parent.navigationController?.navigationItem.titleView?.tintColor = .clear
            }
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.view.frame.origin.x = -UIApplication.getScreenSize()
        }
    }
    
    private func configureView() {
        view.backgroundColor = .clear
        view.frame.origin.x = -UIApplication.getScreenSize()

        addSubviews()
        configureTableView()
        configureTapGesture()
    }

    private func addSubviews() {
        view.addSubview(sideMenuView)
        sideMenuView.addSubview(headerView)
        headerView.addSubview(headerTitle)
        headerView.addSubview(logoView)
        sideMenuView.addSubview(tableView)
        configureConstraints()
    }
    
    private func configureConstraints() {
        sideMenuView.topAnchor.constraint(equalTo: view.topAnchor,constant: 44).isActive = true
        sideMenuViewLeadingContraint = sideMenuView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -view.frame.size.width)
        sideMenuViewLeadingContraint.isActive = true
        sideMenuView.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.6).isActive = true
        sideMenuView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        headerView.topAnchor.constraint(equalTo: sideMenuView.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: sideMenuView.trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 150).isActive = true

        
        NSLayoutConstraint.activate([
            logoView.topAnchor.constraint(equalTo: headerView.topAnchor,constant: 20),
            logoView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor,constant: 15),
            logoView.trailingAnchor.constraint(greaterThanOrEqualTo: headerView.leadingAnchor),
            logoView.widthAnchor.constraint(equalToConstant: 50),
            logoView.heightAnchor.constraint(equalToConstant: 50)
        ])
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: logoView.bottomAnchor,constant: 12),
            headerTitle.leadingAnchor.constraint(equalTo: logoView.leadingAnchor),
            headerTitle.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])
        
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: sideMenuView.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: sideMenuView.bottomAnchor).isActive = true
    }

    private func configureTableView() {
        tableView.backgroundColor = UIColor.whiteGray
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bounces = false
        tableView.register(SideMenuItemCell.self, forCellReuseIdentifier: SideMenuItemCell.identifier)
    }

    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapped() {
        hide()
    }
}

extension SideMenuViewController: UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return false }
        if view === headerView || view.isDescendant(of: tableView) {
            return false
        }
        return true
    }
}

extension SideMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sideMenuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuItemCell.identifier, for: indexPath) as? SideMenuItemCell else {
            fatalError("Could not dequeue cell")
        }
        let item = sideMenuItems[indexPath.row]
        cell.configureCell(icon: item.icon, text: item.name)
        return cell
    }

    
    /// tableView select
    /// - Parameters:
    ///   - tableView: navigation 정보
    ///   - indexPath: (row,column)
    ///   list 에 맞는 presentation으로 navigate 후 dismiss
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = sideMenuItems[indexPath.row]
    
        if item.presentation == .logout{
            DispatchQueue.global().async {
                do{
                    try KeychainItem(service: .bundle, account: .access).deleteItem()
                    try KeychainItem(service: .bundle, account: .refresh).deleteItem()
                }catch{
                    Log.error("logout but KeychainItem deleteError")
                }
            }
        }
        steps.accept(item.presentation)
        hide()
    }
}

