//
//  MyPageContainer.swift
//  CodestackApp
//
//  Created by 박형환 on 2/29/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import CommonUI
import SnapKit
import Then

final class MyPageContainer: BaseView {
    private(set) var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
        return scrollView
    }()
    
    private(set) var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private(set) var profileView: ProfileView = {
        let view = ProfileView(frame: .zero)
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private(set) var segmentList: HistorySegmentedControl = {
        let seg = HistorySegmentedControl(frame: .zero, types: ["그래프", "코드 저장소", "포스팅"])
        seg.selectedSegmentIndex = 0
        return seg
    }()
    
    private(set) var graphContainerView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        return view
    }()
    
    private(set) var codestackListTableView = UITableView().then { tableView in
        tableView.register(CodestackListCell.self, forCellReuseIdentifier: CodestackListCell.identifier)
        tableView.rowHeight = 100
    }
    
    private(set) var myPostingListTableView = UITableView().then { tableView in
        tableView.register(MyPostingListCell.self, forCellReuseIdentifier: MyPostingListCell.identifier)
        tableView.estimatedRowHeight = 220
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private(set) var emptyLabel: UILabel = {
        let label = UILabel()
        return label.headLineLabel(size: 16, text: "💡코드 작성하기💡", color: .label)
    }()
    
    private(set) var emptyDataButton = AddGradientView()
    
    private(set) var editButton = UIButton().then { button in
        button.setTitle("편집", for: .normal)
        button.setTitleColor(.sky_blue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    override func addAutoLayout() {
        addSubview(containerView)
        
        [profileView].forEach{
            containerView.addSubview($0)
        }
        
        containerView.addSubview(graphContainerView)
        containerView.addSubview(segmentList)
        containerView.addSubview(codestackListTableView)
        containerView.addSubview(myPostingListTableView)
        containerView.addSubview(editButton)
        
        codestackListTableView.addSubview(emptyDataButton)
        codestackListTableView.addSubview(emptyLabel)
        
        codestackListTableView.isHidden = true
        myPostingListTableView.isHidden = true
        
        containerView.snp.makeConstraints{
            $0.top.leading.bottom.trailing.equalToSuperview()
            $0.width.equalTo(self.snp.width)
        }
        
        profileView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(250).priority(.low)
        }
        
        segmentList.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        let editButtonWidth = "편집".width(withConstrainedHeight: 40, font: editButton.titleLabel!.font) + 10
        editButton.snp.makeConstraints { make in
            make.centerY.equalTo(segmentList.snp.centerY)
            make.trailing.equalTo(segmentList.snp.trailing)
            make.width.equalTo(editButtonWidth)
        }
        
        codestackListTableView.snp.makeConstraints { make in
            make.top.equalTo(segmentList.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview()
        }
        
        myPostingListTableView.snp.makeConstraints { make in
            make.top.equalTo(segmentList.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview()
        }
        
        graphContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentList.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(180) //.priority(.low)
        }
        
        emptyLabel.isHidden = true
        emptyDataButton.isHidden = true
        
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyDataButton.snp.bottom).offset(8)
        }
        
        emptyDataButton.snp.makeConstraints { make in
            make.centerX.equalTo(codestackListTableView.snp.centerX)
            make.top.equalTo(codestackListTableView.snp.top).offset(40)
            make.width.height.equalTo(50).priority(.high)
        }
    }
}

